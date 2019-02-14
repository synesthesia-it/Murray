//
//  Skeleton+Commands.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Commander
import MurrayKit
extension Skeleton {

    static func commands(for group: Group) {
        group.group("skeleton") {
            $0.command(
                "new",
                Argument<String>("projectName", description: "Project's name. Will be used in replace rules declared in skeleton's Skeletonspec.json"),
                Argument<String>("git", description: "Url of remote git to clone. Use @branch or @tag for specific versions."),
                Flag("verbose")) {
                    projectName, git, verbose in
                    if verbose { Logger.logLevel = .verbose }
                    let repository = Repository(package: git)
                    try Skeleton(projectName: projectName, repository: repository).run()
            }
            
            $0.command(
            "scaffold",
            Flag("verbose")) {
                verbose in
                if verbose { Logger.logLevel = .verbose }
                try Skeleton.scaffold()
            }
        }
    }
}
