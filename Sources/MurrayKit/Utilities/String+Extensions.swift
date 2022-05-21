//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public extension String {
    func firstLowercased() -> String {
        return prefix(1).lowercased() + dropFirst()
    }

    func firstUppercased() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    func camelCaseToSnakeCase() -> String? {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return processCamelCaseRegex(pattern: acronymPattern)?
            .processCamelCaseRegex(pattern: normalPattern)?.lowercased() 
    }

    fileprivate func processCamelCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}

extension String {
    func appendingPathComponent(_ path: String) -> String {
        return (components(separatedBy: "/") + path.components(separatedBy: "/"))
            .filter { !$0.isEmpty }
            .joined(separator: "/")
    }
}
