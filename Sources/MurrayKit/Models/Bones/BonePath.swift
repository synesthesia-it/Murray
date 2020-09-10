//
//  BonePath.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Gloss

public struct BonePath: Glossy, PluginDataContainer {
    public let from: String
    public let to: String
    public let pluginData: [String: JSON]
    public var name: String {
        "from: \(from), to: \(to)"
    }

    public init(from: String, to: String) {
        self.from = from
        self.to = to
        pluginData = [:]
    }

    public init?(json: JSON) {
        guard let from: String = "from" <~~ json,
            let to: String = "to" <~~ json else { return nil }
        self.from = from
        self.to = to
        pluginData = "plugins" <~~ json ?? [:]
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "from" ~~> from,
            "to" ~~> to,
            "plugins" ~~> pluginData
        ])
    }
}
