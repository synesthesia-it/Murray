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
    public init(specName: String, name: String, description: String? = nil, files: [String]) {
        self.specName = specName
        self.name = name
        self.files = files
    }
    public func execute() throws {
        
        let root = folder
        let murrayfile = try root.decodable(MurrayFile.self, at: MurrayFile.fileName)
        
        guard let spec = try murrayfile?.packages.compactMap ({ path -> ObjectReference<BonePackage>? in
            guard let spec = try root.decodable(BonePackage.self, at: path) else { return nil }
            let file = try root.file(at: path)
            return try ObjectReference<BonePackage>(file: file, object: spec)
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

    }
}
