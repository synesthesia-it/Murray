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
    case procedureNotFound(name: String)
}

extension Errors: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .unparsableFile(let filePath): return "Path at \(filePath) is not parsable"
        case .unresolvableString(let string, let context):
            return "Provided string is not properly resolvable\n\nString:\n\(string)\n\nContext:\n\n\(context)"
        case .invalidReplacement: return "Error during replacement"
        case .procedureNotFound(let name): return "Procedure '\(name)' not found."
        case .unknown: return "Some error occurred"
        }
    }
}
