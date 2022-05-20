//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Commander

import Foundation
import MurrayKit
import Rainbow



func commands() -> Group {
    let folder = Folder.current
    #if DEBUG
        Rainbow.enabled = false
    #endif
    
    return Group { group in
        group.listCommand(in: folder)
        group.runCommand(in: folder)
        group.group("bone",
                    Strings.boneDescription) { group in
            group.listCommand(in: folder)
            group.runCommand(in: folder, name: "new")
            
        }
        //            Skeleton.commands(for: $0)
        //            Bone.commands(for: $0)
        //            Scaffold.commands(for: $0)
    }
}
