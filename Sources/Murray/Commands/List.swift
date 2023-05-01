//
//  File.swift
//
//
//  Created by Stefano Mondino on 19/05/22.
//

import Commander
import Foundation
import MurrayKit

extension Commander.Group {
    func listCommand(in folder: Folder, name: String = "list") {
        command(name,
                Flag("verbose", description: .verboseDescription),
                description: .listDescription) { verbose in
            try withVerbose(verbose) {
                try List(folder: folder)
                    .executeAndCatch(verbose: verbose)
            }
        }
    }
}
