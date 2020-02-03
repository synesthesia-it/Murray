//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import Files

public class BoneItemScaffoldCommand: Command {
    let specName: String
    let name: String
    let files: [String]
    public var folder: Folder = .current
    public init(specName: String, name: String, files: [String]) {
        self.specName = specName
        self.name = name
        self.files = files
    }
    public func execute() throws {
        
        let root = folder
        let murrayfile = try root.decodable(MurrayFile.self, at: "Murrayfile.json")
        
        guard let spec = try murrayfile?.specPaths.compactMap ({ path -> ObjectReference<BoneSpec>? in
            guard let spec = try root.decodable(BoneSpec.self, at: path) else { return nil }
            let file = try root.file(at: path)
            return try ObjectReference<BoneSpec>(file: file, object: spec)
        }).first(where: { $0.object.name == specName}) else {
            Logger.log("No spec found")
            return
        }
        
        guard let folder = try spec.file.parent?.createSubfolderIfNeeded(at: name) else {
            Logger.log("No spec found")
            return
        }
        
        _ = try files.map {
            try folder.createFile(at: $0)
        }
        
        let item = BoneItem(name: name, files: files)
        
        let json = item.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        
        let file = try folder.createFileIfNeeded(at: "BoneItem.json", contents: data)
        Logger.log("BoneItem successfully created at \(file.path)", level: .normal)
        
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
