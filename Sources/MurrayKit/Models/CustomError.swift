//
//  Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Files
import Foundation

public enum CustomError: Swift.Error {
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
        case let .missingRequiredParameter(bone, parameter): return "Missing\(parameter.name) parameter for item named \(bone.name)."
        case .invalidJSONString: return "Invalid JSON string"
        case .generic: return "Some error occurred. Please try again later."
        }
    }
}
