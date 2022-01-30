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
    public let procedures: [Procedure]
}

// public extension CodableFile where Object == Package {
//    func procedures() throws -> [CodableFile<Procedure>] {
//        object.procedures.compactMap { procedure in
//            try file.parent?.file(named: procedure)
//        }
//        .map { .init(file: $0)}
//    }
// }
