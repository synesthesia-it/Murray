//
//  File.swift
//  
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation
import Commander
import MurrayKit
import Files

struct ListCommand: Command {
    let folder: Folder
    init(folder: Folder) {
        
        self.folder = folder
    }
    
    func execute() throws {
        let list = try List(folder: folder).list()
        let strings = list.map {
            "\($0.package.object.name.lightGreen).\($0.procedure.name.green): \($0.procedure.description)\n"
        }
        strings.forEach {
            Logger.log($0, level: .normal)
        }
    }
}
extension Commander.Group {
    func listCommand(in folder: Folder, name: String = "list") {
        command(name,
                Flag("verbose", description: Strings.verboseDescription),
                description: Strings.listDescription) { verbose in
            
           ListCommand(folder: folder)
            .executeAndCatch(verbose: verbose)
            
        }
    }
}
