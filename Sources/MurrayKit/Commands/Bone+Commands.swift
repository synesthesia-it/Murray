//
//  Bone+Commands.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Commander

extension Bone {
    static func commands(for group: Group) {
        group.group("template") {
            $0.command(
                "install",
                //                Argument<String>("setup", description: "Setup templates in current folder"),
            Option<String>("boneFile", default: "", description: "Project's Bonefile")) {
                _ in
                try Bone.setup()
            }

            $0.command("list") {
                try Bone.list().forEach {
                    Logger.log("Spec detail: \($0)", level: .none)
                }
            }

            $0.command("create",
                       Argument<String>("boneName", description: ""),
                       Argument<String>("filenames", description: "Filenames separated by | "),
                       Option<String>("specName", default: "Custom", description: "")
            ) { name, files, listName in
                try Bone.newBone(listName: listName, name: name, files: files.components(separatedBy: "|"))
            }

            $0.command("new",
                       Argument<String>("bone", description: ""),
                       Argument<String>("name", description: ""),
                       Option<String>("boneListName", default: "", description: ""),
                       Option<String>("targetName", default: "", description: "")
            ) { bone, name, listName, targetName in
                
                try Bone(boneName: bone, mainPlaceholder: name, context: [:]).run()
                
                //try Bone.newTemplate(bone: bone, name: name, listName: listName, targetName: targetName)

            }
        }
    }
}
