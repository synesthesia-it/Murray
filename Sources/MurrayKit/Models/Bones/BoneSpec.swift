//
//  BoneSpec.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//


import Foundation
import Gloss

/**
    A structure representing a `BoneSpec.json` file.
 
    A BoneSpec should contain groups of Bones that can easily be reused across projects or simply containing some kind of shared features.
 */
public struct BoneSpec: Glossy {
    /**
        Bonespec name used to identify different bonespecs
     */
    public let name: String
    /**
        A quick description for this bonespec
     */
    public let description: String?
    /**
        The groups handled by this bonespec
     */
    public private(set) var groups: [BoneGroup]
    private var groupsByName: [String: BoneGroup] = [:]
    
    public init(name: String) {
        self.name = name
        self.description = "Default description"
        self.groups = []
    }
    
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
    
    public mutating func add(group: BoneGroup) {
        self.groups = self.groups.filter { $0.name != group.name } + [group]
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
