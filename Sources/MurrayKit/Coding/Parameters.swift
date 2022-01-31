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
    CustomDebugStringConvertible,
    CustomStringConvertible,
    Collection
{
    private enum WrappedValue: Codable, Equatable {
        case `nil`
        case string(String)
        case array([Parameters])
        case dictionary([String: Parameters])
        init(_ parameters: Parameters) {
            self = parameters.value
        }
    }

    public var startIndex: Int { array?.startIndex ?? 0 }

    public var endIndex: Int { array?.endIndex ?? 0 }

    private var value: WrappedValue

    private var array: [Parameters]? {
        switch value {
        case let .array(value):
            return value
        default: return nil
        }
    }

    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let dictionary = try? container.decode([String: Parameters].self) {
            value = .dictionary(dictionary)
        } else if let array = try? container.decode([Parameters].self) {
            value = .array(array)
        } else if let value = try? container.decode(String.self) {
            self.value = .string(value)
        } else {
            value = .nil
        }
    }

    public func encode(to encoder: Swift.Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let .dictionary(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case let .string(value):
            try container.encode(value)
        case .nil:
            break
        }
    }

    public init(dictionaryLiteral elements: (String, Parameters)...) {
        value = .dictionary(elements.reduce(into: [:]) {
            $0[$1.0] = $1.1
        })
    }

    public init(stringLiteral value: StringLiteralType) {
        self.value = .string(value)
    }

    public init(arrayLiteral elements: Parameters...) {
        value = .array(elements)
    }

    public init(nilLiteral _: ()) {
        value = .nil
    }

    private init(value: WrappedValue) {
        self.value = value
    }

    public var debugDescription: String {
        switch value {
        case let .dictionary(value):
            return value.debugDescription
        case let .array(value):
            return value.debugDescription
        case let .string(value):
            return value.debugDescription
        case .nil: return String?(nilLiteral: ()).debugDescription
        }
    }

    public var description: String {
        debugDescription
    }

    private func readValue<Value>() -> Value? {
        switch value {
        case let .dictionary(value): return value as? Value
        case let .array(value): return value as? Value
        case let .string(value): return value as? Value
        default: return nil
        }
    }

    public subscript(index: String) -> String? {
        self[index]?.readValue()
    }

    public subscript(index: String) -> [Parameters]? {
        self[index]?.readValue()
    }

    public subscript(index: String) -> Parameters? {
        get {
            switch value {
            case let .dictionary(value): return value[index]
            default: return nil
            }
        }
        set(newValue) {
            switch value {
            case let .dictionary(value):
                var dictionary = value
                dictionary[index] = newValue
                self.value = .dictionary(dictionary)
            default: break
            }
        }
    }

    public subscript(index: Int) -> Parameters? {
        get {
            switch value {
            case let .array(value): return value[index]
            default: return nil
            }
        }
        set(newValue) {
            switch value {
            case let .array(value):
                var array = value
                if let newValue = newValue {
                    array[index] = newValue
                } else if array.count > index {
                    array.remove(at: index)
                }
                self.value = .array(array)
            default: break
            }
        }
    }

    public func index(after i: Int) -> Int {
        array?.index(after: i) ?? 0
    }
}
