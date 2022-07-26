//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
import Yams

public protocol Decoder {
    func decode<Value: Decodable>(_ data: Data) throws -> Value
}

public extension Decoder {
    func decode<Value: Decodable>(_ data: Data,
                                  of _: Value.Type) throws -> Value {
        try decode(data)
    }

    func decode<Value: Decodable>(_ string: String,
                                  encoding: String.Encoding = .utf8,
                                  of _: Value.Type) throws -> Value {
        let data = string.data(using: encoding) ?? Data()
        return try decode(data)
    }
}
