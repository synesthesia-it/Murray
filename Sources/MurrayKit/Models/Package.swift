//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Package: Codable {
    public let name: String
    public let description: String
    public private(set) var procedures: [Procedure]
    
    public mutating func add(procedure: Procedure) {
        if !procedures.contains(procedure) {
            procedures.append(procedure)
        }
    }
//    public let itemPaths: [String]
}

// public extension CodableFile where Object == Package {
//    func items() throws -> [CodableFile<Item>] {
//        try object.itemPaths.compactMap { itemPath in
//            try file.parent?.file(at: itemPath)
//        }
//        .map { try .init(file: $0) }
//    }
// }
