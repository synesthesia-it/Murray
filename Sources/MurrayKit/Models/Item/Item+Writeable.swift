//
//  File.swift
//
//
//  Created by Stefano Mondino on 14/05/22.
//

import Foundation

public extension CodableFile where Object == Item {
    func writeableFiles(context: Template.Context,
                        destinationRoot: Folder) throws -> [WriteableFile] {
        let paths = try object.paths.flatMap {
            try writeableFiles(for: $0,
                               context: context,
                               destinationRoot: destinationRoot)
        }

        let replacements = try object.replacements.map {
            try writeableFile(for: $0, context: context, destinationRoot: destinationRoot)
        }

        return paths + replacements
    }
}
