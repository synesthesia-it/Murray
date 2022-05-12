//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Commander
import Files
import Foundation
import MurrayKit
import Rainbow

func setVerbose(_ flag: Bool) {
    if flag {
        Logger.logLevel = .verbose
    }
}

func commands() -> Group {
    let folder = Folder.current
    #if DEBUG
        Rainbow.enabled = false
    #endif

    return Group { group in
        group.group("bone",
                    "A set of commands to interact with bones in current folder") { group in
            group.command("list",
                          Flag("verbose"),
                          description: "List all available bones.") { verbose in
                setVerbose(verbose)
                try List(folder: folder).execute()
            }
        }
        //            Skeleton.commands(for: $0)
        //            Bone.commands(for: $0)
        //            Scaffold.commands(for: $0)
    }
}

public extension List {
    func execute() throws {
        let list = try self.list()
        let strings = list.map {
            "\($0.package.object.name.lightGreen).\($0.procedure.name.green): \($0.procedure.description)\n"
        }
        strings.forEach { Logger.log($0, level: .normal) }
    }
}
