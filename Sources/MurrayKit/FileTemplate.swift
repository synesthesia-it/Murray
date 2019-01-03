//
//  FileTemplate.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 03/01/2019.
//

import Foundation
import Stencil

public final class FileTemplate {
    private var contents: String
    private var context: [String: Any]
    init(fileContents: String, context: [String: Any]) {
        self.contents = fileContents
        self.context = context
    }
    
    func render() throws -> String {
        
        
        let ext = Extension()
        ext.registerFilter("firstLowercase") { (value: Any?) in
                return (value as? String)?.firstLowercased() ?? value
        }
        ext.registerFilter("firstUppercase") { (value: Any?) in
            return (value as? String)?.firstUppercased() ?? value
        }
        let environment = Environment(extensions:[ext])
        
        let rendered = try environment.renderTemplate(string: contents, context: context)
//        let rendered = try environment.renderTemplate(name: "article_list.html", context: context)
        print (rendered)
        return rendered
    }
    
}
