//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

extension JSONDecoder: Decoder {
    public func decode<Value>(_ data: Data) throws -> Value where Value: Decodable {
        do {
            return try decode(Value.self, from: data)
        } catch {
            switch error {
            case is Errors: throw error
            default: throw Errors.unparsableContent(error.localizedDescription)
            }
        }
    }
}

extension JSONEncoder: Encoder {}
