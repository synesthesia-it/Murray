//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation

extension Folder {
    func firstFile(named names: [String]) throws -> File {
        guard let file: File = names
            .lazy
            .compactMap({ try? file(named: $0) })
            .first
        else {
            throw LocationError(path: path, reason: .missing)
        }
        return file
    }
}
