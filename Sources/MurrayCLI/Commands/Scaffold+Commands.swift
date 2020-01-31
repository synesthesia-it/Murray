////
////  Skeleton+Commands.swift
////  MurrayTests
////
////  Created by Stefano Mondino on 04/01/2019.
////
//
import Foundation
import Commander
import MurrayKit
import Files

struct Scaffold {
    
    static func commands(for group: Group) {
        
        group.group("scaffold") {
            $0.command(
                "skeleton",
                Flag("verbose")) {
                    verbose in
                    try SkeletonScaffoldCommand()
                        .withVerbose(to: verbose)
                        .execute()
            }
            $0.command(
                "murrayfile",
                Flag("verbose")) {
                    verbose in
                    try MurrayfileScaffoldCommand()
                        .withVerbose(to: verbose)
                        .execute()
            }
            $0.command(
                "bonespec",
                Argument<String>("name", description: "Name of the spec. It will be used to identify it across invocations."),
                Argument<String>("path", description: "Path for the spec. Must be empty."),
                Flag("verbose")) {
                    name, path,  verbose in
                    try BoneSpecScaffoldCommand(path: path, name: name)
                        .withVerbose(to: verbose)
                        .execute()
            }
        }
    }
}
