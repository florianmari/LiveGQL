//
//  LiveGQL.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation
import Starscream

class LiveGQL {
    public var socket: WebSocket
    
    init(socket url: String) {
        self.socket = WebSocket(url: URL(string: url)!, protocols: ["graphql-ws"])
        self.socket.delegate = self
        self.socket.connect()
        if let connectMessage = OperationMessage(payload: nil,
                                                 id: nil,
                                                 type: MessageTypes.GQL_CONNECTION_INIT.rawValue).toJSON() {
            if socket.isConnected {
                socket.write(string: connectMessage)
            } else {
                print("LiveGQL: Can't connect to the WebSocket server.")
            }
        }
    }
    
    private func sendMessage(message: OperationMessage) {
        if let serializedMessage = message.toJSON() {
            if socket.isConnected {
                socket.write(string: serializedMessage)
            }
        }
    }
    
    public func subscribe(graphql query: String, name: String) {
        let unserializedMessage = OperationMessage(payload: Payload(query: query,
                                                                    variables: nil,
                                                                    operationName: nil),
                                                   id: name,
                                                   type: MessageTypes.GQL_START.rawValue)
        self.sendMessage(message: unserializedMessage)
    }
    
    public func unsubscribe(subscribtion name: String) {
        let unserializedMessage = OperationMessage(payload: nil,
                                                   id: name,
                                                   type: MessageTypes.GQL_STOP.rawValue)
        self.sendMessage(message: unserializedMessage)
    }
    
    public func closeConnection() {
        let unserializedMessage = OperationMessage(payload: nil,
                                                   id: nil,
                                                   type: MessageTypes.GQL_CONNECTION_TERMINATE.rawValue)
        self.sendMessage(message: unserializedMessage)
    }
    
    deinit {
        self.socket.disconnect(forceTimeout: 0)
        self.socket.delegate = nil
    }
}

extension LiveGQL : WebSocketDelegate {
    public func websocketDidConnect(socket: Starscream.WebSocket) {
        print("LiveGQL: Connected to socket")
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        print("LiveGQL: Disconnected", error ?? "no error")
    }
    
    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        print(text)
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        print(data)
    }
}
