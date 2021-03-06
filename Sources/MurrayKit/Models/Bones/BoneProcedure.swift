//
//  BoneProcedure.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Gloss

/**
    A structure representing a BoneProcedure nested inside `Bonespec.json`

    A BoneProcedure should expose a list of BoneItem paths that will be used by current execution.

 */

public struct BoneProcedure: Glossy, PluginDataContainer {
    /**
        Procedure's **name**. It's the primary key used during executions to identify this procedure from the others
     */
    public let name: String
    /**
        Optional description about current procedure.
     */
    public let description: String?
    /**
        Path of items included in current procedure relative to `Bonespec.json`'s folder
     */

    public let pluginData: [String: JSON]
    public private(set) var itemPaths: [String]

    public init(name: String, description: String = "") {
        self.name = name
        self.description = description
        pluginData = [:]
        itemPaths = []
    }

    public mutating func add(itemPath: String) {
        itemPaths = itemPaths.filter { $0 != itemPath } + [itemPath]
    }

    public init?(json: JSON) {
        guard let name: String = "name" <~~ json else { return nil }
        self.name = name
        description = "description" <~~ json
        itemPaths = "items" <~~ json ?? []
        pluginData = "plugins" <~~ json ?? [:]
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "description" ~~> description,
            "items" ~~> itemPaths,
            "plugins" ~~> pluginData,
        ])
    }
}
