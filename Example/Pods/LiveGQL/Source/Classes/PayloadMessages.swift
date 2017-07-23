//
//  PayloadMessages.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation
import JSONCodable

struct OperationMessage {
    var payload: Payload?
    let id: String?
    let type: String?
}

struct Payload {
    let query: String
    let variables: String?
    let operationName: String?
}

struct PayloadServer {
    let message: String?
}

struct OperationMessageServer {
    var payload: PayloadServer?
    let id: String?
    let type: String?
}

extension OperationMessage: JSONEncodable {
    func toJSON() throws -> Any {
        return try JSONEncoder.create({ (encoder) -> Void in
            try encoder.encode(payload, key: "payload")
            try encoder.encode(id, key: "id")
            try encoder.encode(type, key: "type")
        })
    }
}

extension Payload: JSONEncodable {}

extension OperationMessageServer: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        payload = try decoder.decode("payload")
        id = try decoder.decode("id")
        type = try decoder.decode("type")
    }
}

extension PayloadServer: JSONDecodable {
    init(object: JSONObject) throws {
        let decoder = JSONDecoder(object: object)
        message = try decoder.decode("message")
    }
}
