//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public enum Errors: Swift.Error, Equatable, Hashable {
    public static func == (lhs: Errors, rhs: Errors) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case unparsableFile(String)
    case unresolvableString(string: String, context: JSON)
    case invalidReplacement
    case unknown
    case folderLocationError(String)
    case fileLocationError(String)
    case unreadableFile(String)
    case unwriteableFile(String)
    case copyFolder(String)
    case createFolder(String)
    case deleteFolder(String)
    case procedureNotFound(name: String)
    case murrayfileNotFound(String)
    case invalidPackageName(String)
    case itemAlreadyExists(String)
    case itemNotFound(String)
    case procedureAlreadyExists(String)
}

extension Errors: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .unparsableFile(let filePath): return "Path at \(filePath) is not parsable"
        case .unresolvableString(let string, let context):
            return "Provided string is not properly resolvable\n\nString:\n\(string)\n\nContext:\n\n\(context)"
        case .invalidReplacement: return "Error during replacement"
        case .procedureNotFound(let name): return "Procedure '\(name)' not found."
        case .folderLocationError(let path): return "Invalid folder at \(path)"
        case .fileLocationError(let path): return "Invalid file at \(path)"
        case .unreadableFile(let path): return "Unreadable file at \(path)"
        case .unwriteableFile(let path): return "Unwriteable file at \(path)"
        case .copyFolder(let path): return "Error copying folder at \(path)"
        case .createFolder(let path): return "Error creating folder at \(path)"
        case .deleteFolder(let path): return "Error deleting folder at \(path)"
        case .murrayfileNotFound(let path): return "No valid Murrayfile found in \(path)"
        case .invalidPackageName(let name): return "Provided package name '\(name)' is invalid. Check your Murrayfile."
        case .itemAlreadyExists(let name): return "Item named'\(name)' already exists."
        case .itemNotFound(let name): return "Item named '\(name)' not found"
        case .procedureAlreadyExists(let name): return "Procedure named '\(name)' already exists"
        case .unknown: return "Some error occurred"
        }
    }
}
