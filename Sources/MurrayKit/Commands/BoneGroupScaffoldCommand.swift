//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import Files

public class BoneGroupScaffoldCommand: Command {
    let specName: String
    let name: String
    let items: [String]
    
    public init(specName: String, name: String, items: [String]) {
        self.specName = specName
        self.name = name
        self.items = items
    }
    public func execute() throws {
        
        let root = Folder.current
        let murrayfile = try root.decodable(MurrayFile.self, at: "Murrayfile.json")
        
        guard let spec = try murrayfile?.specPaths.compactMap ({ path -> ObjectReference<BoneSpec>? in
            guard let spec = try root.decodable(BoneSpec.self, at: path) else { return nil }
            let file = try root.file(at: path)
            return try ObjectReference<BoneSpec>(file: file, object: spec)
        }).first(where: { $0.object.name == specName}) else {
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
        
        var group = spec.object.groups.first(where: { $0.name == name }) ?? BoneGroup(name: name, description: "Created from scaffold")
        items.map { $0.file.path(relativeTo: folder) }.forEach {
            group.add(itemPath: $0)
        }
        
        var object = spec.object
        object.add(group:group)
        
        let json = object.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        
        try spec.file.write(data)
        
//        var murrayfile = try root.decodable(MurrayFile.self, at: "Murrayfile.json")
//        murrayfile?.addSpecPath(file.path(relativeTo: root))
//        if let json = murrayfile?.toJSON() {
//             let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
//            _ = try root.createFileWithIntermediateFolders(at: "Murrayfile.json", contents: data, overwriteContents: true)
//        }
//        let pipeline = try BonePipeline(folder: folder)
//        let list = pipeline.list()
//        let strings = list.map { "\($0.spec.object.name).\($0.group.name): \($0.group.description ?? "")"}
//        strings.forEach { Logger.log($0, level: .normal) }
    }
}
