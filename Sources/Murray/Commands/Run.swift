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
                                 description: .runNameDescription),
                Argument<String>("mainPlaceholder",
                                 description: .runMainPlaceholderDescription),
                Flag("verbose", description: .verboseDescription),
                Flag("preview", description: .runPreviewDescription),
                Argument<[String]?>("parameters",
                                    description: .runParametersDescription),
                description: .runDescription) { name, mainPlaceholder, verbose, preview, params in
            
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
