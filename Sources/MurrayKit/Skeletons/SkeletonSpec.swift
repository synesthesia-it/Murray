//
//  SkeletonFile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation

class SkeletonSpec : Codable {
    
    var scripts:[String]?
    var foldersToRename:[String]?
    var filesToRename:[String]?
    private var _filePlaceholder:String?
    
    enum CodingKeys : String, CodingKey {
        case scripts
        case foldersToRename
        case filesToRename
        case _filePlaceholder = "filePlaceholder"
    }
    
    var filePlaceholder: String {
        get { return _filePlaceholder ?? "Skeleton" }
        set { _filePlaceholder = newValue }
    }
    
}
