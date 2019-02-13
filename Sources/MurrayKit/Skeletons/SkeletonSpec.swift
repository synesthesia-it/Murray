//
//  SkeletonFile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation

class SkeletonSpec: Codable {

    var scripts: [String]?
    var foldersToRename: [String]?
    var filesToRename: [String]?
    var _initGit: Bool?
    var environmentPlaceholders: [String: String]?
    private var _filePlaceholder: String?

    enum CodingKeys: String, CodingKey {
        case scripts
        case _initGit = "initGit"
        case foldersToRename
        case filesToRename
        case environmentPlaceholders
        case _filePlaceholder = "filePlaceholder"
    }

    var filePlaceholder: String {
        get { return _filePlaceholder ?? "Skeleton" }
        set { _filePlaceholder = newValue }
    }
    
    var initGit: Bool {
        get { return _initGit ?? false}
        set { _initGit = newValue }
    }
    

}
