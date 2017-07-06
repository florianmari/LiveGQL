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
