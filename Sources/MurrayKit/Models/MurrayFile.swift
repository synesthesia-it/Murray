//
//  BoneFile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Gloss

public struct MurrayFile: Glossy {

    public let specPaths: [String]
    public let environment: JSON
    
    public init?(json: JSON) {
        self.specPaths = "specPaths" <~~ json ?? []
        self.environment = "environment" <~~ json ?? [:]
    }
    
    public func toJSON() -> JSON? {
         return jsonify([
        "specPaths" ~~> specPaths,
        "environment" ~~> environment
        ])
    }
}
