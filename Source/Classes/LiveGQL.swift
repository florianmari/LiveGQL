//
//  LiveGQL.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation
import SocketRocket

open class LiveGQL: NSObject {
    private(set) var socket: SRWebSocket
    public weak var delegate: LiveGQLDelegate?
    fileprivate var queue: [String] = []
    public var verbose = false
    fileprivate var reconnect = false
    fileprivate var params: [String: Any]?
    fileprivate var stateConnect = false {
        didSet {
            self.initServer(connectionParams: self.params, reconnect: self.reconnect)
        }
    }

    
    /// This function init the socket server with a default protocol "graphql-subscriptions"
    ///
    /// - Parameters:
    ///   - url: the url of your websocket (mandatory)
    ///   - graphql: the protocol you want to use (optional)
    public required init(socket url: String, protocol graphql: String = "graphql-subscriptions") {
        socket = SRWebSocket(url: URL(string: url)!, protocols: [graphql])
        super.init()
        socket.delegate = self
        socket.open()
    }

    
    /// This function treats the server response and send to the delegate the raw text
    ///
    /// - Parameter message: raw message from the server
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
                    delegate?.receivedRawMessage(text: message)
                    if !queue.isEmpty {
                        for m in queue {
                            sendRaw(m)
                        }
                    }
                case MessageTypes.GQL_CONNECTION_ERROR.rawValue:
                    print("Error with server connection (maybe connectionParams)")
                case MessageTypes.GQL_CONNECTION_KEEP_ALIVE.rawValue:
                    verbosePrint("Ping by server.")
                case MessageTypes.GQL_DATA.rawValue:
                    delegate?.receivedRawMessage(text: message)
                // self.delegate?.receiveDictMessage!(dict: dict)
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

    
    /// Send init message to the server and manage the reconnect feature
    ///
    /// - Parameters:
    ///   - params: Eventually parameters such login...
    ///   - reconnect: true or false in case of failure
    public func initServer(connectionParams params: [String: Any]?, reconnect: Bool?) {
        if let reconnect = reconnect {
            if reconnect {
                self.reconnect = true
                self.params = params
            }
        }
        let unserializedMessage = InitOperationMessage(
            payload: params,
            id: nil,
            type: MessageTypes.GQL_CONNECTION_INIT.rawValue)
        if let serializedMessage = unserializedMessage.toJSON() {
            sendRaw(serializedMessage)
        }
    }

    
    /// Reconnect function
    fileprivate func reconnectInit() {
        let unserializedMessage = InitOperationMessage(
            payload: params,
            id: nil,
            type: MessageTypes.GQL_CONNECTION_INIT.rawValue)
        if let serializedMessage = unserializedMessage.toJSON() {
            sendRaw(serializedMessage)
        }
    }

    
    /// Use for subscribe to a query and receive the realtime updates
    ///
    /// - Parameters:
    ///   - query: your GraphQL query
    ///   - variables: Differents variables (optional)
    ///   - operationName: OperationName if needed (optional)
    ///   - identifier: Identifier of your query
    public func subscribe(graphql query: String, variables: [String: String]?, operationName: String?, identifier: String) {
        let unserializedMessage = OperationMessage(
            payload: Payload(query: query,
                             variables: variables,
                             operationName: operationName),
            id: identifier,
            type: MessageTypes.GQL_START.rawValue
        )
        sendMessage(unserializedMessage)
    }

    
    /// Unsubscribe to your GraphQL subscription
    ///
    /// - Parameter identifier: Use your query identifier to subscribe
    public func unsubscribe(subscribtion identifier: String) {
        let unserializedMessage = OperationMessage(
            payload: Payload(query: nil,
                             variables: nil,
                             operationName: nil),
            id: identifier,
            type: MessageTypes.GQL_STOP.rawValue
        )
        sendMessage(unserializedMessage)
    }

    
    /// Close the Socket connection
    public func closeConnection() {
        reconnect = false
        let unserializedMessage = OperationMessage(
            payload: Payload(query: nil,
                             variables: nil,
                             operationName: nil),
            id: nil,
            type: MessageTypes.GQL_CONNECTION_TERMINATE.rawValue
        )
        sendMessage(unserializedMessage)
    }

    
    /// Display verbose if enabled
    ///
    /// - Parameter message: LiveGQL internal message
    private func verbosePrint(_ message: String) {
        if verbose {
            print(message)
        }
    }

    
    /// Send message to server
    ///
    /// - Parameter message: OperationMessage
    private func sendMessage(_ message: OperationMessage) {
        if let final = message.toJSON() {
            sendRaw(final)
        } else {
            print("Error while send message")
        }
    }

    
    /// Send raw message to the server
    ///
    /// - Parameter message: string message to send
    fileprivate func sendRaw(_ message: String) {
        socket.readyState == SRReadyState.OPEN ? socket.send(message) : queue.append(message)
    }

    
    /// Get the state of the connection
    ///
    /// - Returns: bool
    public func isConnected() -> Bool {
        return socket.readyState == SRReadyState.OPEN
    }

    deinit {
        self.socket.close()
        self.socket.delegate = nil
    }
}


// MARK: - SRWebSocket implementation
extension LiveGQL: SRWebSocketDelegate {
    public func webSocketDidOpen(_: SRWebSocket!) {
        stateConnect = true
        if queue.isEmpty {
            return
        }
        sendRaw(queue[0])
        queue.remove(at: 0)
    }

    public func webSocket(_: SRWebSocket!, didCloseWithCode _: Int, reason _: String!, wasClean _: Bool) {
        if reconnect {
            socket.open()
        }
    }

    public func webSocket(_: SRWebSocket!, didReceiveMessage message: Any!) {
        serverMessageHandler(String(describing: message!))
    }
}

// MARK: - Delegate methods
@objc public protocol LiveGQLDelegate: class {
    func receivedRawMessage(text: String)
    @objc optional func receiveDictMessage(dict: [String: Any]?)
}
