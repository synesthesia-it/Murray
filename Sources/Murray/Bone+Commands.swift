//
//  Bone+Commands.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Commander
import Files
import Foundation
import MurrayKit
import ShellOut

// swiftlint:disable line_length
struct Bone {
    static func commands(for group: Group) {
        group.group("bone") {
            $0.command("list",
                       Flag("verbose"),
                       description: "List all available bones.") { verbose in
                try BoneListCommand()
                    .withVerbose(to: verbose)
                    .execute()
            }

            $0.command("clone",
                       Argument<String>("git", description: "Url of git"),
                       Argument<String?>("relativePath", description: "Relative path for bone to be cloned. Defaults to .murray"),
                       Flag("verbose"),
                       description: "Clones a remote bonespec from a git repository.") { git, relativePath, verbose in
                try BoneCloneCommand(url: git, targetFolder: relativePath)
                    .withVerbose(to: verbose)
                    .execute()
            }

            $0.command("new",
                       Argument<String>("boneName",
                                        description: "Name of the bone from bonespec (example: model). If multiple bonespecs are being used, use <bonespecName>.<boneName> syntax. Example: myBones.model"),
                       Argument<String>("mainPlaceholder",
                                        description: "Value that needs to be replaced in templates wherever the keyword <name> is used."),
                       Option<String>("context", default: "{}",
                                      description: "A JSON string with further context information used by Stencil template"),
                       Flag("verbose"),
                       Argument<[String]?>("parameters",
                                           description: "Custom parameters for templates. Use key:value syntax (ex: \"author:yourname with spaces\")"),
                       description: "Resolves a bone template with provided parameters and installs it in target path (according to Bonespec.json)") { boneName, mainPlaceholder, contextString, verbose, params in
                try BonePipelineCommand(boneName: boneName, mainPlaceholder: mainPlaceholder, contextString: contextString, params: params ?? [])
                    .withVerbose(to: verbose)
                    .execute()
            }
        }
    }
}
