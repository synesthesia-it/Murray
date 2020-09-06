//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Files
import Foundation

public class MurrayfileScaffoldCommand: Command {
    public var folder: Folder = .current

    public init() {}

    public func execute() throws {
        let spec = MurrayFile()
        let json = spec.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        let file = try folder.createFileIfNeeded(at: MurrayFile.fileName, contents: data)
        Logger.log("Murrayfile successfully created at \(file.path)", level: .normal)
    }
}
