//
//  Bone+Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation

public extension Bone {
    enum Error: String, Swift.Error, CustomStringConvertible {
        case missingSetup
        case missingFile
        case missingSubfolder
        case missingLocalSubfolder
        case missingProjectName
        case missingMainPlaceholder
        case existingFolder
        case gitError
        case shellError
        case missingBonespec
        case missingBonefile
        case bonespecParsingError
        case unknownBone
        case multipleBones
        public var description: String {
            return self.rawValue
        }
        public var localizedDescription: String {
            return self.rawValue
        }
    }
}
