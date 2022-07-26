//
//  File.swift
//
//
//  Created by Stefano Mondino on 25/07/22.
//

import Foundation

public struct Skeleton: Codable {
    private enum CodingKeys: String, CodingKey {
        case scripts
        case paths
        case initializeGit
    }

    public let scripts: [String]
    public let paths: [Item.Path]
    public let initializeGit: Bool

    public init(from decoder: Swift.Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scripts = try container.decode([String].self, forKey: .scripts)
        paths = try container.decode([Item.Path].self, forKey: .paths)
        initializeGit = try container.decodeIfPresent(Bool.self, forKey: .initializeGit) ?? false
    }

    public func encode(to encoder: Swift.Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scripts, forKey: .scripts)
        try container.encode(paths, forKey: .paths)
        if initializeGit {
            try container.encode(initializeGit, forKey: .initializeGit)
        }
    }
}
