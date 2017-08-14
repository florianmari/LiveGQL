//
//  LiveGQL.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation
import Starscream

open class LiveGQL {
    private(set) var socket: WebSocket
    public weak var delegate: LiveGQLDelegate?
    fileprivate var queue: [String] = []
    public var verbose = false
    fileprivate var reconnect = false
    fileprivate var params: [String:Any]?
    fileprivate var stateConnect = false {
        didSet {
            self.initServer(connectionParams: self.params, reconnect: self.reconnect)
        }
    };
    
    public required init(socket url: String) {
        self.socket = WebSocket(url: URL(string: url)!, protocols: ["graphql-ws"])
        self.socket.delegate = self
        self.socket.connect()
    }
    
    fileprivate func serverMessageHandler(_ message: String) {
        if let obj = message.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            do {
                let json = try JSONSerialization.jsonObject(with: obj) as? [String: Any]
                guard let type = json?["type"] as? String else {
                    print("Error JSON parsing")
                    return
                }
                switch type {
                case MessageTypes.GQL_CONNECTION_ACK.rawValue:
                    self.delegate?.receivedRawMessage(text: message)
                    if (!self.queue.isEmpty) {
                        for m in self.queue {
                            self.sendRaw(m)
                        }
                    }
                case MessageTypes.GQL_CONNECTION_ERROR.rawValue:
                    print("Error with server connection (maybe connectionParams)")
                case MessageTypes.GQL_CONNECTION_KEEP_ALIVE.rawValue:
                    self.verbosePrint("Ping by server.")
                case MessageTypes.GQL_DATA.rawValue:
                    self.delegate?.receivedRawMessage(text: message)
                //self.delegate?.receiveDictMessage!(dict: dict)
                case MessageTypes.GQL_ERROR.rawValue:
                    print("LiveGQL: Error return")
                    print(message)
                case MessageTypes.GQL_COMPLETE.rawValue:
                    print("Operation complete.")
                default:
                    print("LiveGQL: Unxpected message from server.")
                }
            } catch {
                print(error)
            }
        }
    }
    
    public func initServer(connectionParams params: [String:Any]?, reconnect: Bool?) {
        if let reconnect = reconnect {
            if (reconnect) {
                self.reconnect = true
                self.params = params
            }
        }
        let unserializedMessage = InitOperationMessage(
            payload: params,
            id: nil,
            type: MessageTypes.GQL_CONNECTION_INIT.rawValue)
        if let serializedMessage = unserializedMessage.toJSON() {
            self.sendRaw(serializedMessage)
        }
    }
    
    fileprivate func reconnectInit() {
        let unserializedMessage = InitOperationMessage(
            payload: self.params,
            id: nil,
            type: MessageTypes.GQL_CONNECTION_INIT.rawValue)
        if let serializedMessage = unserializedMessage.toJSON() {
            self.sendRaw(serializedMessage)
        }
    }
    
    public func subscribe(graphql query: String, identifier: String) {
        let unserializedMessage = OperationMessage(
            payload: Payload(query: query,
                             variables: nil,
                             operationName: nil),
            id: identifier,
            type: MessageTypes.GQL_START.rawValue
        )
        self.sendMessage(unserializedMessage)
    }
    
    public func unsubscribe(subscribtion identifier: String) {
        let unserializedMessage = OperationMessage(
            payload: Payload(query: nil,
                             variables: nil,
                             operationName: nil),
            id: identifier,
            type: MessageTypes.GQL_STOP.rawValue
        )
        self.sendMessage(unserializedMessage)
    }
    
    public func closeConnection() {
        self.reconnect = false
        let unserializedMessage = OperationMessage(
            payload: Payload(query: nil,
                             variables: nil,
                             operationName: nil),
            id: nil,
            type: MessageTypes.GQL_CONNECTION_TERMINATE.rawValue
        )
        self.sendMessage(unserializedMessage)
    }
    
    private func verbosePrint(_ message: String) {
        if verbose {
            print(message)
        }
    }
    
    private func sendMessage(_ message: OperationMessage) {
        if let final = message.toJSON() {
            sendRaw(final)
        } else {
            print("Error while send message")
        }
    }
    
    fileprivate func sendRaw(_ message: String) {
        self.socket.isConnected ? socket.write(string: message) : self.queue.append(message)
    }
    
    public func isConnected() -> Bool {
        return socket.isConnected
    }
    
    deinit {
        self.socket.disconnect(forceTimeout: 0)
        self.socket.delegate = nil
    }
}

extension LiveGQL : WebSocketDelegate {
    public func websocketDidConnect(socket: Starscream.WebSocket) {
        self.stateConnect = true
        if self.queue.isEmpty {
            return
        }
        self.sendRaw(self.queue[0])
        self.queue.remove(at: 0)
        
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        if (self.reconnect) {
            self.socket.connect();
        }
    }
    
    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        self.serverMessageHandler(text)
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        
    }
}

@objc public protocol LiveGQLDelegate: class {
    func receivedRawMessage(text: String)
    @objc optional func receiveDictMessage(dict: [String: Any]?)
}
