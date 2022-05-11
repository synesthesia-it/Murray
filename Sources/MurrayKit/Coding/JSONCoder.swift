//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

extension JSONDecoder: Decoder {
    public func decode<Value>(_ data: Data) throws -> Value where Value: Decodable {
        try decode(Value.self, from: data)
    }
}

extension JSONEncoder: Encoder {}
