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
    func listCommand(in folder: Folder, name: String = "list") {
        command(name,
                Flag("verbose", description: Strings.verboseDescription),
                description: Strings.listDescription) { verbose in
            
           try List(folder: folder)
            .executeAndCatch(verbose: verbose)
            
        }
    }
}
