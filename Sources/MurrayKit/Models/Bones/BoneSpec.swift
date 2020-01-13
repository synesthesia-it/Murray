//
//  BoneSpec.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//


import Foundation
import Gloss

public struct BoneSpec: Glossy {

    public let name: String
    public let description: String?
    public let groups: [BoneGroup]
    private var groupsByName: [String: BoneGroup] = [:]
    public init?(json: JSON) {
        guard let name:String = "name" <~~ json else { return nil }
        self.name = name
        self.description = "description" <~~ json
        self.groups = "groups" <~~ json ?? []
        groupsByName = groups.reduce([:]) { dictionary, group in
            var d = dictionary
            d[group.name] = group
            return d
        }
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "description" ~~> description,
            "groups" ~~> groups,
        ])
    }

    
    public subscript(group: String) -> BoneGroup? {
        get { groupsByName[group] }
    }
    
}
