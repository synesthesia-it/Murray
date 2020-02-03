//
//  Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files

enum CustomError: Swift.Error {
    
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
