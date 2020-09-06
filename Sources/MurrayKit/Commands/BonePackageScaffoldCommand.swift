//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Files
import Foundation

public class BonePackageScaffoldCommand: Command {
    let path: String
    let name: String
    let description: String

    public var folder: Folder = .current

    public init(path: String, name: String, description: String? = nil) {
        self.path = path
        self.name = name
        self.description = description ?? "Created from scaffold"
    }

    public func execute() throws {
        let root = folder

        let folder = try root
            .createSubfolderIfNeeded(at: path)
            .createSubfolderIfNeeded(at: name.firstUppercased())

        let package = BonePackage(name: name, description: description)
        let json = package.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])

        let file = try folder.createFileIfNeeded(at: BonePackage.fileName, contents: data)
        Logger.log("Bonespec successfully created at \(file.path)", level: .normal)

        var murrayfile = try root.decodable(MurrayFile.self, at: MurrayFile.fileName)
        murrayfile?.addSpecPath(file.path(relativeTo: root))
        if let json = murrayfile?.toJSON() {
            let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            _ = try root.createFileWithIntermediateFolders(at: MurrayFile.fileName, contents: data, overwriteContents: true)
        }
    }
}
