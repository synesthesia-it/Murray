//
//  BoneGroup.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Gloss

/**
    A structure representing a BoneGroup nested inside `Bonespec.json`
    
    A BoneGroup should expose a list of BoneItem paths that will be used by current execution.
        
 */

public struct BoneGroup: Glossy {
    /**
        Group's **name**. It's the primary key used during executions to identify this group from the others
     */
    public let name: String
    /**
        Optional description about current group.
     */
    public let description: String?
    /**
        Path of items included in current group relative to `Bonespec.json`'s folder
     */
    public let itemPaths: [String]
    
    public init?(json: JSON) {
        guard let name:String = "name" <~~ json else { return nil }
        self.name = name
        self.description = "description" <~~ json
        self.itemPaths = "items" <~~ json ?? []
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "description" ~~> description,
            "items" ~~> itemPaths,
        ])
    }
    
}
