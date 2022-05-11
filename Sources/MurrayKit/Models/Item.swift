//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public struct Item: Codable, CustomStringConvertible {
    
    public struct Parameter: Codable, CustomStringConvertible {
        private enum CodingKeys: String, CodingKey {
            case name
            case isRequired
        }
        public let name: String
        public let isRequired: Bool
        public var description: String { name }
        
        public init(from decoder: Swift.Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey:   .name)
            self.isRequired = try container.decodeIfPresent(Bool.self, forKey: .isRequired) ?? false
        }
    }
    
    public struct Path: Codable, CustomStringConvertible {
        public let from: String
        public let to: String
        private let plugins: Parameters?
        public var pluginData: JSON? {
            plugins?.dictionaryValue
        }
        public var description: String {
            "From: \(from) to: \(to)"
        }
    }
    
    public struct Replacement: Codable, CustomStringConvertible {
        
        private enum CodingKeys: String, CodingKey {
            case placeholder
            case destination
            case text
            case source
        }
        
        public let placeholder: String
        public let destination: String
        public let text: String?
        public let source: String?
        
        public init(from decoder: Swift.Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.placeholder = try container.decode(String.self, forKey: .placeholder)
            self.destination = try container.decode(String.self, forKey: .destination)
            self.text = try container.decodeIfPresent(String.self, forKey: .text)
            self.source = try container.decodeIfPresent(String.self, forKey: .source)
            if text == nil, source == nil { throw Errors.invalidReplacement }
        }
        
        public var description: String {
            destination
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case parameters
        case paths
        case plugins
        case _description = "description"
        case replacements
    }
    
    public let name: String
    public let parameters: [Parameter]
    public private(set) var paths: [Path]
    private let plugins: Parameters?
    private let _description: String?
    public var description: String { _description ?? name }
    public var pluginData: JSON? {
        plugins?.dictionaryValue
    }
    
    public let replacements: [Replacement]
    
}
