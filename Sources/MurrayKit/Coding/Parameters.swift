//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Parameters: Codable,
    Equatable,
    ExpressibleByDictionaryLiteral,
    ExpressibleByStringLiteral,
    ExpressibleByArrayLiteral,
    ExpressibleByNilLiteral,
    CustomDebugStringConvertible
{
    private var dictionary: [String: Parameters]?
    private var array: [Parameters]?
    private var value: String?

    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.singleValueContainer()
        dictionary = try? container.decode([String: Parameters].self)
        array = try? container.decode([Parameters].self)
        value = try? container.decode(String.self)
    }

    public func encode(to encoder: Swift.Encoder) throws {
        var container = encoder.singleValueContainer()
        if let dictionary = dictionary {
            try container.encode(dictionary)
        } else if let array = array {
            try container.encode(array)
        } else if let value = value {
            try container.encode(value)
        }
    }

    public init(dictionaryLiteral elements: (String, Parameters)...) {
        dictionary = elements.reduce(into: [:]) {
            $0[$1.0] = $1.1
        }
    }

    public init(stringLiteral value: StringLiteralType) {
        self.value = value
    }

    public init(arrayLiteral elements: Parameters...) {
        array = elements
    }

    public init(nilLiteral _: ()) {}

    public var debugDescription: String {
        if let value = value {
            return value.debugDescription
        }
        if let array = array {
            return array.debugDescription
        }
        if let dictionary = dictionary {
            return dictionary.debugDescription
        }
        return String(reflecting: self)
    }
}
