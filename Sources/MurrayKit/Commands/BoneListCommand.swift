//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import Files

public class BoneListCommand: Command {
    
    public var folder: Folder = .current
    
    public init() {}
    
    public func execute() throws {

        let pipeline = try BonePipeline(folder: folder)
        let list = pipeline.list()
        let strings = list.map { "\($0.spec.object.name).\($0.group.name): \($0.group.description ?? "")"}
        strings.forEach { Logger.log($0, level: .normal) }
    }
}
