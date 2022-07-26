//
//  File.swift
//
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public enum Content {
    case file(File)
    case text(String)

    public func contents() throws -> String {
        switch self {
        case let .file(file): return try file.readAsString()
        case let .text(text): return text
        }
    }
}

extension Content: Resolvable {
    public func resolve(with context: Template.Context) throws -> String {
        try contents().resolve(with: context)
    }
}
