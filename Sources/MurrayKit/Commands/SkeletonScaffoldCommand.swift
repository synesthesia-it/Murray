//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Files
import Foundation

public class SkeletonScaffoldCommand: Command {
    public var folder: Folder = .current

    public init() {}

    public func execute() throws {
        let spec = SkeletonSpec()
        let json = spec.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        let file = try folder.createFileIfNeeded(at: "Skeletonfile.json", contents: data)
        Logger.log("Skeletonfile successfully created at \(file.path)", level: .normal)
    }
}
