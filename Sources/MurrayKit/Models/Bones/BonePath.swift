//
//  BonePath.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Gloss

public struct BonePath: Glossy {
    public let from: String
    public let to: String

    public init(from: String, to: String) {
        self.from = from
        self.to = to
    }

    public init?(json: JSON) {
        guard let from: String = "from" <~~ json,
            let to: String = "to" <~~ json else { return nil }
        self.from = from
        self.to = to
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "from" ~~> from,
            "to" ~~> to,
        ])
    }
}
