//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import Files

public class BoneSpecScaffoldCommand: Command {
    let path: String
    let name: String
    
    public init(path: String, name: String) {
        self.path = path
        self.name = name
    }
    public func execute() throws {
        
        let root = Folder.current
        
        let folder = try root
            .createSubfolderIfNeeded(at: path)
            .createSubfolderIfNeeded(at: name.firstUppercased())
        
        let spec = BoneSpec(name: name)
        let json = spec.toJSON() ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        
        let file = try folder.createFileIfNeeded(at: "Bonespec.json", contents: data)
        Logger.log("Bonespec successfully created at \(file.path)")
        
        var murrayfile = try root.decodable(MurrayFile.self, at: "Murrayfile.json")
        murrayfile?.addSpecPath(file.path(relativeTo: root))
        if let json = murrayfile?.toJSON() {
             let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            _ = try root.createFileWithIntermediateFolders(at: "Murrayfile.json", contents: data, overwriteContents: true)
        }
//        let pipeline = try BonePipeline(folder: folder)
//        let list = pipeline.list()
//        let strings = list.map { "\($0.spec.object.name).\($0.group.name): \($0.group.description ?? "")"}
//        strings.forEach { Logger.log($0, level: .normal) }
    }
}
