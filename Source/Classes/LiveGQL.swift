//
//  LiveGQL.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation
import Starscream
import JSONCodable

open class LiveGQL {
    private(set) var socket: WebSocket
    public weak var delegate: LiveGQLDelegate?
    fileprivate var queue: [String] = []
    public var verbose = false
    
    public required init(socket url: String) {
        self.socket = WebSocket(url: URL(string: url)!, protocols: ["graphql-ws"])
        self.socket.delegate = self
        self.socket.connect()
    }
    
    private func sendMessage(_ message: OperationMessage) {
        do {
            let serializedMessage = try message.toJSONString()
            self.sendRaw(serializedMessage)
        } catch {
            print(error)
        }
    }
    
    fileprivate func sendRaw(_ message: String) {
        self.socket.isConnected ? socket.write(string: message) : self.queue.append(message)
    }
    
    private func verbosePrint(_ message: String) {
        if verbose {
            print(message)
        }
    }
    
    fileprivate func serverMessageHandler(_ message: String) {
        do {
            let dict = self.convertToDictionary(text: message)
            let obj = try OperationMessageServer(object: dict!)
            switch obj.type {
            case MessageTypes.GQL_CONNECTION_ACK.rawValue?:
                if (!self.queue.isEmpty) {
                    for m in self.queue {
                        self.sendRaw(m)
                    }
                }
            case MessageTypes.GQL_CONNECTION_ERROR.rawValue?:
                print("Error with server connection (maybe connectionParams)")
            case MessageTypes.GQL_CONNECTION_KEEP_ALIVE.rawValue?:
                self.verbosePrint("Ping by server.")
            case MessageTypes.GQL_DATA.rawValue?:
                self.delegate?.receivedRawMessage(text: message)
                self.delegate?.receiveDictMessage!(dict: dict)
            case MessageTypes.GQL_ERROR.rawValue?:
                print("LiveGQL: Error return")
                print(message)
            case MessageTypes.GQL_COMPLETE.rawValue?:
                self.verbosePrint("Operation complete.")
            default:
                print("LiveGQL: Unxpected message from server.")
            }
        } catch {
            print(error)
        }
    }
    
    private func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public func initServer(connectionParams params: [String:String]?) {
        self.socket.connect()
        let unserializedMessage = InitOperationMessage(
            payload: params,
            id: nil,
            type: MessageTypes.GQL_CONNECTION_INIT.rawValue)
        do {
            let serializedMessage = try unserializedMessage.toJSONString()
            self.sendRaw(serializedMessage)
        } catch {
            print(#function, error)
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
            payload: nil,
            id: identifier,
            type: MessageTypes.GQL_STOP.rawValue
        )
        self.sendMessage(unserializedMessage)
    }
    
    public func closeConnection() {
        let unserializedMessage = OperationMessage(
            payload: nil,
            id: nil,
            type: MessageTypes.GQL_CONNECTION_TERMINATE.rawValue
        )
        self.sendMessage(unserializedMessage)
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
        if self.queue.isEmpty {
            return
        }
        self.sendRaw(self.queue[0])
        self.queue.remove(at: 0)
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
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
