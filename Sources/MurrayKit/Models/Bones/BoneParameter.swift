//
//  BonePath.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Gloss

struct BoneParameter: Glossy {
    let name: String
    let isRequired: Bool
    let description: String?
    init?(json: JSON) {
        guard let name: String = "name" <~~ json else { return nil }
        self.name = name
        self.isRequired = "isRequired" <~~ json ?? false
        self.description = "description" <~~ json
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "isRequired" ~~> isRequired,
            "description" ~~> description
        ])
    }
    
}
