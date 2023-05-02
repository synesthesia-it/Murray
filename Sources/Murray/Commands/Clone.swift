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
                Argument<String>("path",
                                 description: .cloneGitDescription),
                Flag("verbose", description: .verboseDescription),
                Flag("copyFromLocalFolder", description: .cloneForceLocalPathDescription),
                Argument<String?>("subfolder",
                                  description: .cloneGitSubfolderDescription),
                Argument<[String]?>("parameters",
                                    description: .runParametersDescription),
                description: .cloneDescription) { name, path, verbose, copyFromLocalFolder, subfolder, parameters in

            Clone(path: path,
                  folder: folder,
                  subfolderPath: subfolder,
                  mainPlaceholder: name,
                  copyFromLocalFolder: copyFromLocalFolder,
                  parameters: parameters)
                .executeAndCatch(verbose: verbose)
        }
    }
}
