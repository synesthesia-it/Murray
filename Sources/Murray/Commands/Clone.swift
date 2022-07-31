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
                Argument<String?>("subfolder",
                                  description: .cloneGitSubfolderDescription)
                Argument<[String]?>("parameters",
                                    description: .runParametersDescription),
                description: .cloneDescription) { name, git, verbose, subfolder, parameters in

            try Clone(folder: folder,
                      subfolderPath: subfolder,
                      git: git,
                      context: parameters)
        }
    }
}
