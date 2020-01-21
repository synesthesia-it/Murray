//
//  Bone+Commands.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files
import Commander
import MurrayKit
import ShellOut
struct Bone {
        static func commands(for group: Group) {
    
            group.group("bone") {
                $0.command("list",
                           Flag("verbose"),
                           description: "List all available bones.") { verbose in
                            
                            let folder = Folder.current
                            let pipeline = try BonePipeline(folder: folder)
                            let list = try pipeline.list()
                            let strings = list.map { "\($0.spec.object.name).\($0.group.name): \($0.group.description ?? "")"}
                            strings.forEach { Logger.log($0) }
                }
                $0.command("new",
                                       Argument<String>("boneName", description: "Name of the bone from bonespec (example: model). If multiple bonespecs are being used, use <bonespecName>.<boneName> syntax. Example: myBones.model"),
                                       Argument<String>("mainPlaceholder", description: "Value that needs to be replaced in templates wherever the keyword <name> is used."),
                                       Option<String>("context", default: "{}", description: "A JSON string with further context information used by Stencil template"),
                                       VariadicOption<String>("param", default: [""], flag: Character("p"), description: "Custom parameters that will be resolved in Stencil templates"),
                                       Flag("verbose"),
                                       description: "Resolves a bone template with provided parameters and installs it in target path (according to Bonespec.json)"
                
                            ) { boneName, mainPlaceholder, contextString, params, verbose in
                
                                if verbose { Logger.logLevel = .verbose }
                                
                                let pipeline = try BonePipeline(folder: Folder.current, murrayFileName: "Murrayfile.json", pluginManager: .shared)
                                try pipeline.execute(boneName: boneName, with: ["name": mainPlaceholder])
                                
                                var context:JSON = ["name": mainPlaceholder]
                                
                                
//                                guard let jsonConversion = try? JSONSerialization.jsonObject(with: contextString.data(using: .utf8) ?? Data(), options: []),
//                                    var context = jsonConversion as? Bone.Context else {
//                                    throw Error.invalidContext
//                                }
//                                params.map {
//                                    $0.components(separatedBy: ":")
//                                }
//                                    .filter { $0.count == 2}
//                                    .map { $0.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}}
//                                    .compactMap {array -> (key: String, value:String)? in
//                                        guard let key = array.first,
//                                            let value = array.last else { return nil }
//                                        return (key: key, value: value)}
//                                    .forEach {
//                                        context[$0.key] = $0.value
//                                }
//                                try Bone(boneName: boneName, mainPlaceholder: mainPlaceholder, context: context).run()
            }
            }
    }
}
//    static func commands(for group: Group) {
//        
//        group.group("bone") {
//            $0.command(
//                "setup",
//            Option<String>("boneFile", default: "", description: "Project's Bonefile. Currently not implemented"),
//            Flag("verbose"),
//            description: "Setup project to use bones cloned from repositories specified in Skeletonspec.json") {
//                _, verbose in
//                if verbose { Logger.logLevel = .verbose }
//                try Bone.setup()
//            }
//
//            $0.command("list",
//                       Flag("verbose"),
//                       Flag("json"),
//                       description: "Lists all bones in current setup."
//                       ) { verbose, json in
//                if verbose { Logger.logLevel = .verbose }
//                if json {
//                    let bones = try Bone.bones()
//                    let encoded = try JSONEncoder().encode(bones)
//                    print(String(data: encoded, encoding: .utf8) ?? "Unable to parse json")
//                } else {
//                Logger.log("Listing all bones:\n", level: .verbose)
//                try Bone.list().forEach {
//                    Logger.log($0 + "\n", level: .none)
//                }
//                        }
//            }
//
//            $0.command("scaffold",
//                       Argument<String>("boneName", description: "Name of custom bone that will be created and added to Bonespec.json"),
//                       Argument<String>("filenames", description: "Filenames separated by `|` (pipe). Empty files will be created."),
//                       Option<String>("specName", default: "Custom", description: "Name of bonespec. If a bonespec with same name is found, it will be updated, otherwise it will be created."),
//                       Flag("verbose"),
//                       description: "Creates or updates a custom Bonespec"
//            ) { name, files, listName, verbose in
//                if verbose { Logger.logLevel = .verbose }
//                try Bone.newBone(listName: listName, name: name, files: files.components(separatedBy: "|"))
//            }
//
//            $0.command("new",
//                       Argument<String>("boneName", description: "Name of the bone from bonespec (example: model). If multiple bonespecs are being used, use <bonespecName>.<boneName> syntax. Example: myBones.model"),
//                       Argument<String>("mainPlaceholder", description: "Value that needs to be replaced in templates wherever the keyword <name> is used."),
//                       Option<String>("context", default: "{}", description: "A JSON string with further context information used by Stencil template"),
//                       VariadicOption<String>("param", default: [""], flag: Character("p"), description: "Custom parameters that will be resolved in Stencil templates"),
//                       Flag("verbose"),
//                       description: "Resolves a bone template with provided parameters and installs it in target path (according to Bonespec.json)"
//                       
//            ) { boneName, mainPlaceholder, contextString, params, verbose in
//
//                if verbose { Logger.logLevel = .verbose }
//                guard let jsonConversion = try? JSONSerialization.jsonObject(with: contextString.data(using: .utf8) ?? Data(), options: []),
//                    var context = jsonConversion as? Bone.Context else {
//                    throw Error.invalidContext
//                }
//                params.map {
//                    $0.components(separatedBy: ":")
//                }
//                    .filter { $0.count == 2}
//                    .map { $0.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}}
//                    .compactMap {array -> (key: String, value:String)? in
//                        guard let key = array.first,
//                            let value = array.last else { return nil }
//                        return (key: key, value: value)}
//                    .forEach {
//                        context[$0.key] = $0.value
//                }
//                try Bone(boneName: boneName, mainPlaceholder: mainPlaceholder, context: context).run()
//            }
//        }
//    }
//}
