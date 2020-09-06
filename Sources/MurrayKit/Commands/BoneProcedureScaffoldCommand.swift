//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Files
import Foundation

public class BoneProcedureScaffoldCommand: Command {
    let specName: String
    let name: String
    let description: String
    let items: [String]
    public var folder = Folder.current
    public init(specName: String, name: String, description: String? = nil, items: [String]) {
        self.specName = specName
        self.name = name
        self.description = description ?? "Created from scaffold"
        self.items = items
    }

    public func execute() throws {
        let root = folder
        let murrayfile = try root.decodable(MurrayFile.self, at: MurrayFile.fileName)

        guard let spec = try murrayfile?.packages.compactMap({ path -> ObjectReference<BonePackage>? in
            guard let spec = try root.decodable(BonePackage.self, at: path) else { return nil }
            let file = try root.file(at: path)
            return try ObjectReference<BonePackage>(file: file, object: spec)
        }).first(where: { $0.object.name == specName }) else {
            Logger.log("No spec found")
            return
        }

        guard let folder = spec.file.parent else {
            Logger.log("No spec found")
            return
        }

        let items = try folder.subfolders
            .compactMap { try? $0.file(named: "BoneItem.json") }
            .compactMap { file -> ObjectReference<BoneItem>? in
                guard let item = try file.decodable(BoneItem.self) else { return nil }
                return try ObjectReference(file: file, object: item)
            }.filter {
                self.items.contains($0.object.name)
            }

        var procedure = spec.object.procedures.first(where: { $0.name == name }) ?? BoneProcedure(name: name, description: description)
        items.map { $0.file.path(relativeTo: folder) }.forEach {
            procedure.add(itemPath: $0)
        }

        var object = spec.object
        object.add(procedure: procedure)

        let json = object.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])

        try spec.file.write(data)
    }
}
