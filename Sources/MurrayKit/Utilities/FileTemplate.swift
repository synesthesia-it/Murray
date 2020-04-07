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
    private var context: BoneContext
    
    public init(fileContents: String, context: BoneContext) {
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

        ext.registerFilter("snakeCase") { (value: Any?) in
            return (value as? String)?.camelCaseToSnakeCase() ?? value
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

        do {
            return try environment.renderTemplate(string: contents, context: context.context)
        } catch  {
            throw CustomError.unresolvableString(string: contents, context: context)
        }

    }

}

public extension String {
    func resolved(with context: BoneContext) throws -> String {
        return try FileTemplate(fileContents: self, context: context).render()
    }
}
