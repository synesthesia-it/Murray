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

struct Skeleton {
    
    static func commands(for group: Group) {
        
        group.group("skeleton") {
            $0.command(
                "new",
                Argument<String>("projectName", description: "Project's name. Will be used in replace rules declared in skeleton's Skeletonspec.json"),
                Argument<String>("path", description: "Url of remote git to clone or local path to copy. Use @branch or @tag for specific versions."),
                Flag("verbose")) {
                    projectName, path, verbose in
                    if verbose { Logger.logLevel = .verbose }
                    try SkeletonPipeline(folder: Folder.current, projectName: projectName)
                        .execute(projectPath: path, with: [:])
            }
        }
    }
}
