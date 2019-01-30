//
//  Bone+Commands.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Commander
import MurrayKit
extension Bone {
    static func commands(for group: Group) {
        
        group.group("bone") {
            $0.command(
                "setup",
            Option<String>("boneFile", default: "", description: "Project's Bonefile. Currently not implemented")) {
                _ in
                try Bone.setup()
            }

            $0.command("list", description: "Lists all bones in current setup.") {
                try Bone.list().forEach {
                    Logger.log("Spec detail: \($0)", level: .none)
                }
            }

            $0.command("scaffold",
                       Argument<String>("boneName", description: ""),
                       Argument<String>("filenames", description: "Filenames separated by | "),
                       Option<String>("specName", default: "Custom", description: "")
            ) { name, files, listName in
                try Bone.newBone(listName: listName, name: name, files: files.components(separatedBy: "|"))
            }

            $0.command("new",
                       Argument<String>("boneName", description: "Name of the bone from bonespec (example: model). If multiple bonespecs are being used, use <bonespecName>.<boneName> syntax. Example: myBones.model"),
                       Argument<String>("mainPlaceholder", description: "Value that needs to be replaced in templates wherever the keyword <name> is used."),
                       Option<String>("context", default: "{}", description: "A JSON string with further context information used by Stencil template"),
                       VariadicOption<String>("param", default: [""], flag: Character("p"), description: "")
                       
            ) { boneName, mainPlaceholder, contextString, params in

                
                guard let jsonConversion = try? JSONSerialization.jsonObject(with: contextString.data(using: .utf8) ?? Data(), options: []),
                    var context = jsonConversion as? Bone.Context else {
                    throw Error.invalidContext
                }
                
                params.map {
                    $0.components(separatedBy: ":")
                }
                    .filter { $0.count == 2}
                    .map { $0.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}}
                    .compactMap {array -> (key: String, value:String)? in
                        guard let key = array.first,
                            let value = array.last else { return nil }
                        return (key: key, value: value)}
                    .forEach {
                        context[$0.key] = $0.value
                }
                try Bone(boneName: boneName, mainPlaceholder: mainPlaceholder, context: context).run()
            }
        }
    }
}
