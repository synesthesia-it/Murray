//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Package: Codable, Hashable {
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

public extension CodableFile where Object == Package {
//    func items() throws -> [CodableFile<Item>] {
//        try object.itemPaths.compactMap { itemPath in
//            try file.parent?.file(at: itemPath)
//        }
//        .map { try .init(file: $0) }
//    }

    func items() throws -> [CodableFile<Item>] {
        guard let folder = file.parent else { return [] }
        let automatic: [CodableFile<Item>] = file.parent?.subfolders
            .compactMap { folder in
                if let file = try? folder.file(named: folder.name) {
                    return file
                }
                return CodableFile<Item>.Encoding.allValidExtensions
                    .compactMap {
                        try? folder.file(named: "\(folder.name).\($0)")
                    }.first
            }
            .compactMap { try? .init(file: $0) } ?? []

        let fromProcedures: [CodableFile<Item>] = try Set(object.procedures
            .flatMap { $0.itemPaths })
            .map { try folder.file(at: $0) }
            .map { try CodableFile<Item>(file: $0) }

        return Array(Set(automatic + fromProcedures)).sorted {
            $0.object.name < $1.object.name
        }
    }
}
