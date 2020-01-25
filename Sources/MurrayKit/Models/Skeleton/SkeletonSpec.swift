//
//  Skeleton.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 24/01/2020.
//

import Foundation
import Gloss

public struct SkeletonSpec: Glossy {

    let scripts: [String]
    let folders:[BonePath]
    let files: [BonePath]
    
    public init?(json: JSON) {
        
         folders = "folders" <~~ json ?? []
         files = "files" <~~ json ?? []
         scripts = "scripts" <~~ json ?? []
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "folders" ~~> folders,
            "files" ~~> files,
            "scripts" ~~> scripts
        ])
    }
}
