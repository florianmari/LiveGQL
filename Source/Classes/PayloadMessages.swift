//
//  PayloadMessages.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation

struct OperationMessage: JSONSerializable {
    var payload: Payload
    let id: String?
    let type: String?
}

struct InitOperationMessage: JSONSerializable {
    let payload: [String: Any]?
    let id: String?
    let type: String?
}

struct Payload: JSONSerializable {
    let query: String?
    let variables: [String: String]?
    let operationName: String?
}

struct PayloadServer {
    let message: String
}

struct OperationMessageServer {
    var payload: PayloadServer?
    let id: String?
    let type: String?
}
