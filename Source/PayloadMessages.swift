//
//  PayloadMessages.swift
//  graphql-subscription
//
//  Created by Florian Mari on 06/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation

struct Payload: JSONSerializable {
    let query: String
    let variables: String?
    let operationName: String?
}

struct OperationMessage : JSONSerializable{
    let payload: JSONSerializable?
    let id: String?
    let type: String?
}
