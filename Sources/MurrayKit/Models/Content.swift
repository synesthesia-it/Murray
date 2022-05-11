//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
import Files

enum Content {
    case file(File)
    case text(String)
    
    func contents() throws -> String {
        switch self {
        case .file(let file): return try file.readAsString()
        case .text(let text): return text
        }
    }
}

extension Content: Resolvable {
    func resolve(with context: Template.Context) throws -> String {
        try contents().resolve(with: context)
    }
}


