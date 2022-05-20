//
//  File.swift
//  
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation
import Commander
import MurrayKit


extension Commander.Group {
    func runCommand(in folder: Folder, name: String = "run") {
        command(name,
                Argument<String>("name",
                                 description: Strings.runNameDescription),
                Argument<String>("mainPlaceholder",
                                 description: Strings.runMainPlaceholderDescription),
                Flag("verbose", description: Strings.verboseDescription),
                Flag("preview", description: Strings.runPreviewDescription),
                Argument<[String]?>("parameters",
                                    description: Strings.runParametersDescription),
                description: Strings.runDescription) { name, mainPlaceholder, verbose, preview, params in
            
            Run(folder: folder,
                       mainPlaceholder: mainPlaceholder,
                       name: name,
                       preview: preview,
                       verbose: verbose,
                       params: params)
            .executeAndCatch(verbose: verbose)
            
        }
    }
}
