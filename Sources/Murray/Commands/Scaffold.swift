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
    
    private func murrayfile(in folder: Folder, name: String = "murrayfile") {
        command(name,
                Flag("verbose"),
                Option<String?>("format", default: nil, description: .scaffoldFileFormatDescription),
                description: .scaffoldMurrayfileDescription) { verbose, format in
            
            Scaffold
                .murrayfile(encoding: .init(rawValue: format) ?? .yml, in: folder)
                .executeAndCatch(verbose: verbose)
            
        }
    }
    
    func scaffoldCommand(in folder: Folder, name: String = "scaffold") {
        group(name) {
            $0.murrayfile(in: folder)
        }
        
    }
}
