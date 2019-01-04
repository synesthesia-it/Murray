//
//  Skeleton+Error.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation

public extension Skeleton {
    enum Error: String, Swift.Error, CustomStringConvertible{
        case missingProjectName
        case existingFolder
        case gitError
        case gitEmpty
        case shellError
        case missingSpec
        case invalidSpec
        public var description: String {
            return self.rawValue
        }
        public var localizedDescription: String {
            return self.rawValue
        }
    }
}
