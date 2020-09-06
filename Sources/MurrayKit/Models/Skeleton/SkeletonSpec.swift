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
    let folders: [BonePath]
    let files: [BonePath]
    let initGit: Bool

    public init() {
        scripts = []
        folders = []
        files = []
        initGit = false
    }

    public init?(json: JSON) {
        folders = "folders" <~~ json ?? []
        files = "files" <~~ json ?? []
        scripts = "scripts" <~~ json ?? []
        initGit = "initGit" <~~ json ?? false
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "folders" ~~> folders,
            "files" ~~> files,
            "scripts" ~~> scripts,
            "initGit" ~~> initGit,
        ])
    }
}
