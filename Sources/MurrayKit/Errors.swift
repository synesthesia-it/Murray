//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public enum Errors: Swift.Error, Equatable {
    public static func == (lhs: Errors, rhs: Errors) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case unparsableFile(String)
    case unresolvableString(string: String, context: JSON)
    case invalidReplacement
    case unknown
}
