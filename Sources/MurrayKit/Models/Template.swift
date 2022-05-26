//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

import Stencil

public struct Template {
    public struct Context: ExpressibleByDictionaryLiteral, CustomStringConvertible {
        public var description: String { values.description }
        
        public let values: JSON
        
        public init(_ parameters: Parameters, environment: Parameters = [:]) {
            self.values = (environment.dictionaryValue ?? [:])
                .merging(parameters.dictionaryValue ?? [:]) { _, other in other }
        }
        public init(_ values: JSON) {
            self.values = values
        }
        public init(dictionaryLiteral elements: (String, AnyHashable)...) {
            self.values = elements.reduce(into: [:]) { $0[$1.0] = $1.1 }
        }
        
        public func adding(_ newValues: JSON) -> Context {
            .init(values.merging(newValues) { original, _ in original })
        }
   
    }
    
    public let contents: String
    public let context: Context
    
    public init(_ contents: String, context: Context) {
        self.contents = contents
        self.context = context
    }
    
    public init(_ file: File, context: Context) throws {
        self.contents = try file.readAsString()
        self.context = context
    }
    
    public func resolve(recursive: Bool = true) throws -> String {
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
