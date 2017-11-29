//
//  JSONHelper.swift
//  DevGQLMain
//
//  Created by Florian Mari on 23/07/2017.
//  Copyright © 2017 Florian. All rights reserved.
//

import Foundation

protocol JSONRepresentable {
    var JSONRepresentation: Any { get }
}

protocol JSONSerializable: JSONRepresentable {
}

extension JSONSerializable {
    var JSONRepresentation: Any {
        var representation = [String: Any]()

        for case let (label?, value) in Mirror(reflecting: self).children {
            switch value {
            case let value as JSONRepresentable:
                representation[label] = value.JSONRepresentation
            case let value as NSObject:
                representation[label] = value
            default:
                break
            }
        }
        return representation
    }
}

extension JSONSerializable {
    func toJSON() -> String? {
        let representation = JSONRepresentation

        guard JSONSerialization.isValidJSONObject(representation) else {
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: representation, options: [])
            return String(data: data, encoding: String.Encoding.utf8)
        } catch {
            return nil
        }
    }
}
