//
//  Item.swift
//
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public struct Item: Codable, CustomStringConvertible, Hashable {
    public struct Parameter: Codable, CustomStringConvertible, Hashable {
        private enum CodingKeys: String, CodingKey {
            case name
            case isRequired
            case values
            case optionalDescription = "description"
        }

        public let name: String
        public let isRequired: Bool
        private var optionalDescription: String?
        public var description: String { optionalDescription ?? name }
        public var values: [String]?

        public init(name: String,
                    description: String? = nil,
                    isRequired: Bool = true,
                    values: [String]? = nil) {
            self.name = name
            self.isRequired = isRequired
            self.values = values
            optionalDescription = description
        }

        public init(from decoder: Swift.Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? false
            values = try container.decodeIfPresent([String].self, forKey: .values)
            optionalDescription = try container.decodeIfPresent(String.self, forKey: .optionalDescription)
        }
    }

    public struct Path: Codable, CustomStringConvertible, Hashable {
        public let from: String
        public let to: String
        private let plugins: Parameters?
        public var pluginData: Parameters? {
            plugins
        }

        public var description: String {
            "From: \(from) to: \(to)"
        }

        public init(from: String, to: String, plugins: Parameters? = nil) {
            self.from = from
            self.to = to
            self.plugins = plugins
        }

        public func customParameters() -> JSON {
            ["_path": ["_from": from,
                       "_to": to],
             "_filename": ["_from": from.filename,
                           "_to": to.filename]]
        }
    }

    public struct Replacement: Codable, CustomStringConvertible, Hashable {
        private enum CodingKeys: String, CodingKey {
            case placeholder
            case destination
            case text
            case source
            case plugins
        }

        public let placeholder: String
        public let destination: String
        public let text: String?
        public let source: String?
        public let plugins: Parameters?
        public var pluginData: Parameters? { plugins }
        public init(from decoder: Swift.Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            placeholder = try container.decode(String.self, forKey: .placeholder)
            destination = try container.decode(String.self, forKey: .destination)
            text = try container.decodeIfPresent(String.self, forKey: .text)
            plugins = try container.decodeIfPresent(Parameters.self, forKey: .plugins)
            source = try container.decodeIfPresent(String.self, forKey: .source)
            if text == nil, source == nil {
                throw Errors.invalidReplacement
            }
        }

        public var description: String {
            destination
        }

        public func customParameters() -> JSON {
            ["_replacement": try? dictionary()]
        }
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case parameters
        case paths
        case plugins
        case optionalDescription = "description"
        case replacements
    }

    public let name: String
    public let parameters: [Parameter]
    public private(set) var paths: [Path]
    private let plugins: Parameters?
    private let optionalDescription: String?
    public var description: String { optionalDescription ?? name }
    public var pluginData: Parameters? {
        plugins
    }

    public let replacements: [Replacement]

    public init(name: String,
                parameters: [Item.Parameter],
                paths: [Item.Path],
                plugins: Parameters?,
                optionalDescription: String?,
                replacements: [Item.Replacement]) {
        self.name = name
        self.parameters = parameters
        self.paths = paths
        self.plugins = plugins
        self.optionalDescription = optionalDescription
        self.replacements = replacements
    }

    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        parameters = try container.decode([Item.Parameter].self, forKey: .parameters)
        paths = try container.decode([Item.Path].self, forKey: .paths)
        plugins = try container.decodeIfPresent(Parameters.self, forKey: .plugins)
        optionalDescription = try container.decodeIfPresent(String.self, forKey: .optionalDescription)
        replacements = try container.decodeIfPresent([Item.Replacement].self, forKey: .replacements) ?? []
    }
}

extension CodableFile where Object == Item {
    func files(with context: Template.Context) throws -> [CodableFile<Item.Path>] {
        guard let folder = file.parent else { return [] }
        return try object
            .paths
            .map { try .init(file: folder.file(at: $0.from.resolve(with: context))) }
    }

    func customParameters() -> JSON {
        ["_item": try? object.dictionary()]
    }
}

private extension String {
    var filename: String {
        components(separatedBy: "/").last ?? self
    }
}
