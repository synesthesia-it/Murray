//
//  Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files

public enum CustomError: Swift.Error {
    
    case undecodable(file: File, type: Any.Type)
    
    case fileNotFound(path: String, folder: Folder?)
    
    case unableToCreateFile(path: String, folder: Folder?, contents: Data?)
    case unableToCreateFolder(path: String, folder: Folder?)
    
    case invalidPath(path: String)
    
    case unresolvableString(string: String, context: BoneContext)
    
    case boneGroupNotFound(name: String, spec: String?)
    
    case invalidMurrayfile
    
    case missingRequiredParameter(bone: BoneItem, parameter: BoneParameter)
    
    case invalidJSONString
    case generic

}

extension CustomError: CustomStringConvertible {
    public var description: String {

        switch self {
        case .undecodable(let file, let type): return "JSON file at \(file.path) is invalid and not convertible in \(type) entity"
        case .fileNotFound(let path, let folder): return "File at \(path) in folder \(folder?.path ?? "-") not found."
        case .unableToCreateFile(let path, let folder, _): return "Unable to create file at \(path) in folder \(folder?.path ?? "")."
        case .unableToCreateFolder(let path, let folder): return "Unable to create folder \(path) in folder \(folder?.path ?? "")"
        case .invalidPath(let path): return "Invalid path at \(path)"
        case .unresolvableString: return "Provided string is not resolvable."
        case .boneGroupNotFound(let name, _): return "Group named \(name) not found."
        case .invalidMurrayfile: return "Provided Murrayfile.json is invalid."
        case .missingRequiredParameter(let bone, let parameter): return "Missing\(parameter.name) parameter for item named \(bone.name)."
        case .invalidJSONString: return "Invalid JSON string"
        case .generic: return "Some error occurred. Please try again later."
        }
    }
}
