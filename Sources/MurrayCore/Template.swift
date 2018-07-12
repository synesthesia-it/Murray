//
//  Template.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Foundation
import Files
import ShellOut
import Commander

public final class Template {
    static func commands(for group:Group) {
        group.group("template") {
            $0.command(
                "new",
                Argument<String>("projectName", description: "Name of project"),
                Option<String>("git", default:"git@github.com:synesthesia-it/Skeleton.git", description:"Project's template git url")) {
                    projectName, git in
                    guard let url = URL(string: git) else {
                        return
                    }
                    try Project(projectName: projectName, git: url).run()
            }
        }
        
    }
}
