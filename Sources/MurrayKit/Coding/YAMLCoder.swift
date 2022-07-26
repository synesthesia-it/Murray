//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
import Yams

extension YAMLDecoder: Decoder {
    public func decode<Value>(_ data: Data) throws -> Value where Value: Decodable {
        do {
            return try decode(Value.self, from: data)
        } catch {
            switch error {
            case let DecodingError.dataCorrupted(inner):
                throw inner.underlyingError ?? error
            default: throw error
            }
        }
    }
}

extension YAMLEncoder: Encoder {
    public func encode<Value>(_ object: Value) throws -> Data where Value: Encodable {
        let string: String = try encode(object)
        return string.data(using: .utf8) ?? Data()
    }
}
