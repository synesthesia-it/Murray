//
//  Skeleton+Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation

public extension Skeleton {
    enum Error: Swift.Error, CustomStringConvertible {
        case missingProjectName
        case existingFolder(String)
        case alreadyExistingSpec
        case gitError
        case gitEmpty
        case shellError
        case missingSpec
        case invalidSpec
        public var description: String {
            switch self {
                
            case .missingProjectName: return "Project name is missing"
            case .existingFolder(let path): return "Folder at \(path) already exists"
            case .gitEmpty: return "Project cloned from git is empty (no subfolders found)"
            case .alreadyExistingSpec: return "Skeletonspec.json already exists"
            case .gitError: return "Error cloning from git"
            case .shellError: return "Shell command error"
            case .missingSpec: return "Missing Skeletonspec.json"
            case .invalidSpec: return "Invalid Skeletonspec.json"
            }
        }
        public var localizedDescription: String {
            return self.description
        }
    }
}
