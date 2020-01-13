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
    
    
 */

public struct BoneGroup: Glossy {

    public let name: String
    public let description: String?
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
