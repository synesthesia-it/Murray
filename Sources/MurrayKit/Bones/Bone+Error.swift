//
//  Bone+Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation

public extension Bone {
    enum Error: Swift.Error, CustomStringConvertible {
        case missingSetup
        case missingFile(String)
        case copy(String)
        case missingSubfolder(String)
        case missingLocalSubfolder(String)
        case missingProjectName
        case missingMainPlaceholder
        case existingFolder(String)
        case gitError
        case shellError
        case missingBonespec(String)
        case invalidBonespec(String)
        case bonespecParsing(String)
        
        case invalidContext
        case unknownBone(String)
        case multipleBones(String,[(list: BoneSpec, bone: BoneItem)] )
        case existingBone(String)
        case bonespecGeneration
        public var description: String {
            switch self {
            case .existingFolder(let path): return "Folder at \(path) already exists"
            case .missingSubfolder(let path): return "Folder at \(path) has no subfolders "
            case .missingBonespec(let path): return "No Bonespec.json file found at \(path)"
            case .invalidBonespec(let path): return "Bonespec is unreadable at \(path)"
            case .bonespecParsing(let path): return "Invalid Bonespec format at \(path). Unable to parse."
            case .missingSetup: return "Murray is not initialized for current project. Please run `murray bone setup` and try again."
            case .unknownBone(let name): return "No bone found for \(name). Please run `murray bone list` for a complete list of available bones."
            case .multipleBones(let name, let tuples): return "Multiple bones found for \(name): \(tuples.map { $0.list.name + "." + $0.bone.name }.joined(separator: ", "))"
            case .missingLocalSubfolder(let path): return "Murray folder for local bones not found at \(path)"
            case .missingFile(let path): return "Missing file at \(path)"
            case .copy(let path): return "Error copying file to \(path)"
            case .existingBone(let name): return "Bone named \(name) already exists"
            case .bonespecGeneration: return "Error creating bonespec"
            case .missingProjectName: return "Project name is missing"
            case .missingMainPlaceholder: return "Main placeholder (name) is missing"
            case .gitError: return "Error cloning from git"
            case .shellError: return "Shell command error"
            case .invalidContext: return "Provided context parameter is invalid"
            }
        }
        public var localizedDescription: String {
            return self.description
        }
    }
}
