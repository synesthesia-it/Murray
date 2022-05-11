//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
import Files
import Stencil

struct Template {
    struct Context: ExpressibleByDictionaryLiteral, CustomStringConvertible {
        var description: String { values.description }
        
        fileprivate let values: JSON
        
        init(_ parameters: Parameters, environment: Parameters = [:]) {
            self.values = (environment.dictionaryValue ?? [:])
                .merging(parameters.dictionaryValue ?? [:]) { _, other in other }
        }
        init(dictionaryLiteral elements: (String, Any)...) {
            self.values = elements.reduce(into: [:]) { $0[$1.0] = $1.1 }
        }
   
    }
    
    let contents: String
    let context: Context
    
    init(_ contents: String, context: Context) {
        self.contents = contents
        self.context = context
    }
    init(_ file: File, context: Context) throws {
        self.contents = try file.readAsString()
        self.context = context
    }
    
    func resolve(recursive: Bool = true) throws -> String {
        let ext = Extension()
        ext.registerFilter("firstLowercase") { (value: Any?) in
            (value as? String)?.firstLowercased() ?? value
        }
        ext.registerFilter("firstUppercase") { (value: Any?) in
            (value as? String)?.firstUppercased() ?? value
        }

        ext.registerFilter("snakeCase") { (value: Any?) in
            (value as? String)?.camelCaseToSnakeCase() ?? value
        }
        
        let environment = Environment(extensions: [ext])
        do {
            let rendered = try environment.renderTemplate(string: contents, context: context.values)
            if recursive, rendered != contents {
                return try Template(rendered, context: context).resolve(recursive: recursive)
            } else {
                return rendered
            }
        } catch {
            throw Errors.unresolvableString(string: contents, context: context.values)
        }
    }
}
