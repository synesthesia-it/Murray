//
//  Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Files
import Foundation

public enum CustomError: Swift.Error {
    public enum Code: Int {
        case undecodable = 0

        case fileNotFound = 1

        case unableToCreateFile = 2
        case unableToCreateFolder = 3
        case invalidPath = 4

        case unresolvableString = 5

        case boneProcedureNotFound = 6

        case invalidMurrayfile = 7

        case missingRequiredParameter = 8

        case invalidJSONString = 9
        case generic = 10
    }

    case undecodable(file: File, type: Any.Type)

    case fileNotFound(path: String, folder: Folder?)

    case unableToCreateFile(path: String, folder: Folder?, contents: Data?)
    case unableToCreateFolder(path: String, folder: Folder?)

    case invalidPath(path: String)

    case unresolvableString(string: String, context: BoneContext)

    case boneProcedureNotFound(name: String, package: String?)

    case invalidMurrayfile

    case missingRequiredParameter(bone: BoneItem, parameter: BoneParameter)

    case invalidJSONString
    case generic
}

extension CustomError {
    var code: Code {
        switch self {
        case .generic: return .generic
        case .undecodable: return .undecodable
        case .fileNotFound(path: _, folder: _): return .fileNotFound
        case .unableToCreateFile(path: _, folder: _, contents: _): return .unableToCreateFile
        case .unableToCreateFolder(path: _, folder: _): return .unableToCreateFolder
        case .invalidPath(path: _): return .invalidPath
        case .unresolvableString(string: _, context: _): return .unresolvableString
        case .boneProcedureNotFound(name: _, package: _): return .boneProcedureNotFound
        case .invalidMurrayfile: return .invalidMurrayfile
        case .missingRequiredParameter(bone: _, parameter: _): return .missingRequiredParameter
        case .invalidJSONString: return .invalidJSONString
        }
    }
}

extension CustomError: LocalizedError {
    public var errorDescription: String? { description }
}

extension CustomError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .undecodable(file, type): return "JSON file at \(file.path) is invalid and not convertible in \(type) entity"
        case let .fileNotFound(path, folder): return "File at \(path) in folder \(folder?.path ?? "-") not found."
        case let .unableToCreateFile(path, folder, _): return "Unable to create file at \(path) in folder \(folder?.path ?? "")."
        case let .unableToCreateFolder(path, folder): return "Unable to create folder \(path) in folder \(folder?.path ?? "")"
        case let .invalidPath(path): return "Invalid path at \(path)"
        case .unresolvableString: return "Provided string is not resolvable."
        case let .boneProcedureNotFound(name, _): return "Group named \(name) not found."
        case .invalidMurrayfile: return "Provided Murrayfile.json is missing or invalid."
        case let .missingRequiredParameter(bone, parameter): return "Missing \(parameter.name) parameter for item named \(bone.name)."
        case .invalidJSONString: return "Invalid JSON string"
        case .generic: return "Some error occurred. Please try again later."
        }
    }
}
