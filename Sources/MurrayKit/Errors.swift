//
//  Errors.swift
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
    case unparsableContent(String)
    case unresolvableString(string: String, context: JSON)
    case invalidReplacement
    case unknown
    case folderLocationError(String)
    case fileLocationError(String)
    case unreadableFile(String)
    case unwriteableFile(String)
    case copyFolder(String)
    case moveFolder(String)
    case createFolder(String)
    case deleteFolder(String)
    case deleteFile(String)
    case procedureNotFound(name: String)
    case multipleProceduresFound(name: String)
    case murrayfileNotFound(String)
    case invalidPackageName(String)
    case itemAlreadyExists(String)
    case itemNotFound(String)
    case procedureAlreadyExists(String)
    case noValidSkeletonFound(String)
    case invalidGitRepository(String)
    case missingRequiredParameters([String])
    case invalidParameters([String])
}

extension Errors: LocalizedError, CustomStringConvertible {
    public var description: String { localizedDescription.red }
    var localizedDescription: String {
        switch self {
        case let .missingRequiredParameters(parameters):
            return "Missing required parameters: \(parameters.joined(separator: ", "))"
        case let .invalidParameters(parameters):
            return "These parameters are invalid: \(parameters.joined(separator: ", "))"
        case let .unparsableFile(filePath): return "Path at \(filePath) is not parsable"
        case let .unparsableContent(error): return "Unparsable content: \(error)"
        case let .unresolvableString(string, context):
            return "Provided string is not properly resolvable\n\nString:\n\(string)\n\nContext:\n\n\(context)"
        case .invalidReplacement: return "Error during replacement"
        case let .procedureNotFound(name): return "Procedure '\(name)' not found."
        case let .multipleProceduresFound(name): return "Multiple procedures found for name \(name). Use syntax PackageName.procedureName instead."
        case let .folderLocationError(path): return "Invalid folder at \(path)"
        case let .fileLocationError(path): return "Invalid file at \(path)"
        case let .unreadableFile(path): return "Unreadable file at \(path)"
        case let .unwriteableFile(path): return "Unwriteable file at \(path)"
        case let .copyFolder(path): return "Error copying folder at \(path)"
        case let .moveFolder(path): return "Error moving folder to \(path)"
        case let .createFolder(path): return "Error creating folder at \(path)"
        case let .deleteFolder(path): return "Error deleting folder at \(path)"
        case let .deleteFile(path): return "Error deleting file at \(path)"
        case let .murrayfileNotFound(path): return "No valid Murrayfile found in \(path)"
        case let .invalidPackageName(name): return "Provided package name '\(name)' is invalid. Check your Murrayfile."
        case let .itemAlreadyExists(name): return "Item named'\(name)' already exists."
        case let .itemNotFound(name): return "Item named '\(name)' not found"
        case let .procedureAlreadyExists(name): return "Procedure named '\(name)' already exists"
        case let .noValidSkeletonFound(path): return "No valid skeleton file found at \(path)"
        case let .invalidGitRepository(path): return "Invalid git repository at \(path)"
        case .unknown: return "Some error occurred"
        }
    }
}
