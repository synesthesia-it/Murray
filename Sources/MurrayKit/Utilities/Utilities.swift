//
//  Utilities.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Gloss
public typealias JSON = Gloss.JSON

public extension String {
    func firstLowercased() -> String {
        return prefix(1).lowercased() + dropFirst()
    }

    func firstUppercased() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    func camelCaseToSnakeCase() -> String {
        let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
        let normalPattern = "([a-z0-9])([A-Z])"
        return processCamelCaseRegex(pattern: acronymPattern)?
            .processCamelCaseRegex(pattern: normalPattern)?.lowercased() ?? lowercased()
    }

    fileprivate func processCamelCaseRegex(pattern: String) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: count)
        return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
    }
}
