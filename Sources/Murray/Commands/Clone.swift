//
//  File.swift
//  
//
//  Created by Stefano Mondino on 26/07/22.
//

import Commander
import Foundation
import MurrayKit

extension Commander.Group {
    func cloneCommand(in folder: Folder,
                      name: String = "clone") {
        command(name,
                Argument<String>("mainPlaceholder",
                                 description: .runMainPlaceholderDescription),
                Argument<String>("git",
                                 description: .cloneGitDescription),
                Flag("verbose", description: .verboseDescription),
                Argument<[String]?>("parameters",
                                    description: .runParametersDescription),
                description: .cloneDescription) { name, git, verbose, parameters in

            try List(folder: folder)
                .executeAndCatch(verbose: verbose)
        }
    }
}

