//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Foundation
import Commander

public class Menu {
    public static var menu : Group {
        return Group {
            $0.group("project") {
                $0.command(
                    "new",
                    Argument<String>("projectName", description: "Name of project"),
                    Option<String>("git", default:"git@github.com:synesthesia-it/Murray.git", description:"Project's template git url")) {
                            projectName, git in
                            guard let url = URL(string: git) else {
                                return
                            }
                            try Project(projectName: projectName, git: url).run()
                        
                }
            }
           
            $0.command("file", {
                print ("New file")
            })
        }
    }
    
    
    
}
