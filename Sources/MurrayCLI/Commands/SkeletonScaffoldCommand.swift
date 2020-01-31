//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import MurrayKit
import Files

public class SkeletonScaffoldCommand: Command {
    public init() {}
    func execute() throws {
        let folder = Folder.current
        let spec = SkeletonSpec()
        let json = spec.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        let file = try folder.createFile(named: "Skeletonfile.json", contents: data)
        Logger.log("Skeletonfile successfully created at \(file.path)")
//        let pipeline = try BonePipeline(folder: folder)
//        let list = pipeline.list()
//        let strings = list.map { "\($0.spec.object.name).\($0.group.name): \($0.group.description ?? "")"}
//        strings.forEach { Logger.log($0, level: .normal) }
    }
}
