//
//  BonePath.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Gloss

public struct BoneParameter: Glossy {
    public let name: String
    public let isRequired: Bool
    public let description: String?
    public init?(json: JSON) {
        guard let name: String = "name" <~~ json else { return nil }
        self.name = name
        self.isRequired = "isRequired" <~~ json ?? false
        self.description = "description" <~~ json
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "isRequired" ~~> isRequired,
            "description" ~~> description
        ])
    }
    
}
