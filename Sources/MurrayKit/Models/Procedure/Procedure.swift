//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
/** Swift model for a procedure
 
 A procedure represents a sequence of items executed with the same context.
 
*/
public struct Procedure: Codable, Hashable {

    private enum CodingKeys: String, CodingKey {
        case name
        case optionalDescription = "description"
        case plugins
        case itemPaths = "items"
    }
    
    public let name: String
    
    private let optionalDescription: String?
    public var description: String { optionalDescription ?? name }
    
    private let plugins: Parameters?
    public var pluginData: Parameters? { plugins }
    
    public private(set) var itemPaths: [String]
    
    internal init(name: String,
                  description: String?,
                  plugins: Parameters?,
                  itemPaths: [String]) {
        self.name = name
        self.optionalDescription = description
        self.plugins = plugins
        self.itemPaths = itemPaths
    }
    
    public mutating func add(itemPath: String) {
        itemPaths = itemPaths.filter { $0 != itemPath } + [itemPath]
    }
}
