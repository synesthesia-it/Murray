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
    public init(fileContents: String, context: [String: Any]) {
        self.contents = fileContents
        self.context = context
    }

    public func render() throws -> String {

        let ext = Extension()
        ext.registerFilter("firstLowercase") { (value: Any?) in
                return (value as? String)?.firstLowercased() ?? value
        }
        ext.registerFilter("firstUppercase") { (value: Any?) in
            return (value as? String)?.firstUppercased() ?? value
        }
        
        ext.registerFilter("swiftType") { (value: Any?) in
            guard let v = value else { return value }
            
            switch v {
            case is Int: return "Int"
            case is Bool: return "Bool"
            case is Double: return "Double"
            case is Float: return "Float"
            case is String: return "String"
            default: return "Any"
            }
        }
        let environment = Environment(extensions: [ext])

        let rendered = try environment.renderTemplate(string: contents, context: context)

        return rendered
    }

}

extension String {
    
    func resolved(with context: [String: Any]) throws -> String {
        return try FileTemplate(fileContents: self, context: context).render()
    }
}
