//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import MurrayKit
import Files

public class BoneListCommand: Command {
    public init() {}
    func execute() throws {
        let folder = Folder.current
        let pipeline = try BonePipeline(folder: folder)
        let list = pipeline.list()
        let strings = list.map { "\($0.spec.object.name).\($0.group.name): \($0.group.description ?? "")"}
        strings.forEach { Logger.log($0, level: .normal) }
    }
}
