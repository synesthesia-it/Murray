//
//  File.swift
//
//
//  Created by Stefano Mondino on 26/07/22.
//

import Foundation

public protocol RootFile: Codable {
    static var defaultName: String { get }
}

public extension CodableFile where Object: RootFile {
    init(in folder: Folder,
         defaultName: String = Object.defaultName) throws {
        let extensions = ["", ".json", ".yml", ".yaml"]
        let names = extensions.map { defaultName + $0 }
        let file = try folder.firstFile(named: names)
        try self.init(file: file)
    }

    func encoding<Object: Codable>(_: Object.Type = Object.self) -> CodableFile<Object>.Encoding {
        switch file.extension?.lowercased() ?? "" {
        case "yaml", "yml": return .yml
        default: return .json
        }
    }
}
