//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Procedure: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case name
        case _description = "description"
        case plugins
        case itemPaths = "items"
    }
    
    public let name: String
    
    private let _description: String?
    public var description: String { _description ?? name }
    
    private let plugins: Parameters?
    public var pluginData: JSON { plugins?.dictionaryValue ?? [:] }
    
    public private(set) var itemPaths: [String]
    
    public mutating func add(itemPath: String) {
        itemPaths = itemPaths.filter { $0 != itemPath } + [itemPath]
    }
}

public struct PackagedProcedure {

    public let package: CodableFile<Package>
    public let procedure: Procedure
    
    internal init(package: CodableFile<Package>, procedure: Procedure) {
        self.package = package
        self.procedure = procedure
    }
    
    init(package: CodableFile<Package>,
         procedureName name: String) throws {
        self.package = package
        guard let procedure = package
            .object
            .procedures
            .first (where: { $0.name == name || $0.name == "\(package.object.name).\(name)"})
        else {
            throw Errors.procedureNotFound(name: name)
        }
        self.procedure = procedure
    }
}
