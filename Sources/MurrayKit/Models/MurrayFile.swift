//
//  BoneFile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Gloss

struct MurrayFile: Glossy {

    let specPaths: [String]
    let environment: JSON
    
    init?(json: JSON) {
        self.specPaths = "specPaths" <~~ json ?? []
        self.environment = "environment" <~~ json ?? [:]
    }
    
    func toJSON() -> JSON? {
         return jsonify([
        "specPaths" ~~> specPaths,
        "environment" ~~> environment
        ])
    }
}
