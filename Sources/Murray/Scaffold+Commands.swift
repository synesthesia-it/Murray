import Commander
import Files
//
//  Skeleton+Commands.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 04/01/2019.
//
//
import Foundation
import MurrayKit

// swiftlint:disable function_body_length
struct Scaffold {
    static func commands(for group: Group) {
        group.group("scaffold") {
            $0.command(
                "skeleton",
                Flag("verbose")
            ) { verbose in
                try SkeletonScaffoldCommand()
                    .withVerbose(to: verbose)
                    .execute()
            }
            $0.command(
                "murrayfile",
                Flag("verbose")
            ) { verbose in
                try MurrayfileScaffoldCommand()
                    .withVerbose(to: verbose)
                    .execute()
            }
            $0.command(
                "package",
                Argument<String>("name", description: "Name of the spec. It will be used to identify it across invocations."),
                Argument<String>("path", description: "Path for the spec. Must be empty."),
                Option<String?>("description", default: nil, description: "A description for new package. Should explain what's included inside and its main purpose."),
                Flag("verbose")
            ) { name, path, _, verbose in
                try BonePackageScaffoldCommand(path: path, name: name)
                    .withVerbose(to: verbose)
                    .execute()
            }
            $0.command(
                "procedure",
                Argument<String>("spec", description: "Name of the spec"),
                Argument<String>("name", description: "Name of the bone procedure. It will be used to identify its folder."),
                Argument<[String]>("items", description: "Items for this bonegroup."),
                Option<String?>("description", default: nil, description: "A description for new procedure. Should explain what's included inside and its main purpose."),
                Flag("verbose")
            ) { spec, name, items, description, verbose in
                try BoneProcedureScaffoldCommand(specName: spec, name: name, description: description, items: items)
                    .withVerbose(to: verbose)
                    .execute()
            }
            $0.command(
                "item",
                Argument<String>("spec", description: "Name of the spec"),
                Argument<String>("name", description: "Name of the bone item. It will be used to identify its folder."),
                Argument<[String]>("files", description: "Template files to create."),
                Flag("verbose")
            ) { spec, name, files, verbose in
                try BoneItemScaffoldCommand(specName: spec, name: name, files: files)
                    .withVerbose(to: verbose)
                    .execute()
            }
        }
    }
}
