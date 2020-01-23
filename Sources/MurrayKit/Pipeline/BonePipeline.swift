//
//  BonePipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files

public struct ObjectReference<T> {
     public let file: File
     public let object: T
     
     public init (file: File, object: T?) throws {
         guard let object = object else {
             throw CustomError.generic
         }
         self.file = file
         self.object = object
     }
}

public struct ListObject {
    public let murrayFile: MurrayFile
    public let spec: ObjectReference<BoneSpec>
    public let group: BoneGroup
}

public struct BonePipeline {

    public let murrayFile: MurrayFile
    
    public let specs: [String: ObjectReference<BoneSpec>]
    let folder: Folder
//    var tree: [TreeObject] = []
    let pluginManager: PluginManager
    public init(folder: Folder, murrayFileName: String = "Murrayfile.json", pluginManager: PluginManager = .shared) throws {
        
        guard let file = try folder.file(named: murrayFileName).decodable(MurrayFile.self),
                file.environment["name"] == nil
        else {
            throw CustomError.invalidMurrayfile
        }
        
        self.pluginManager = pluginManager
        self.folder = folder
        self.murrayFile = file
        
        specs = try file.specPaths
            
            .reduce([:]) {
                var specs = $0
                let file = try folder.file(at: $1)
                guard let spec = try file.decodable(BoneSpec.self)
                    else { throw CustomError.undecodable(file: file, type: BoneSpec.self) }
                specs[spec.name] = try ObjectReference(file: file, object: spec)
                return specs
        }
    }
    
    public func list() -> [ListObject]{
        specs.values
            .flatMap { spec in
                spec.object.groups.map { group in ListObject(murrayFile: murrayFile, spec: spec, group: group)}
        }
    }
    
    func items(from spec: ObjectReference<BoneSpec>, group: BoneGroup) throws -> [ObjectReference<BoneItem>] {
        return try group.itemPaths
            .compactMap { try spec.file.parent?.file(at: $0) }
            .map { try ObjectReference(file: $0, object: $0.decodable(BoneItem.self)) }
    }
    
    public func transform(path: BonePath, sourceFolder: Folder, with context:BoneContext) throws {
        let reader = TemplateReader(source: sourceFolder)
        let contents = try reader
            .file(from: path, context: context)
            .readAsString()
            .resolved(with: context)
        
        let writer = TemplateWriter(destination: self.folder)
        try writer.write(contents, to: path, context: context)
        
    }
    
    public func replace(from replacement: BoneReplacement, sourceFolder: Folder, with context: BoneContext) throws {
        
        let reader = TemplateReader(source: self.folder)
        let contents = try reader
            .file(from: replacement.destinationPath, context: context)
            .readAsString()
        
        let text: String
        
        if let source = replacement.sourcePath {
            
            let sourceReader = TemplateReader(source: sourceFolder)
            text = try sourceReader
            .file(from: source, context: context)
            .readAsString()
            .resolved(with: context)
            
        } else if let inline = replacement.text {
           text = try inline.resolved(with: context)
        } else {
            throw CustomError.fileNotFound(path: replacement.sourcePath ?? "", folder: sourceFolder)
        }

        let replaced = contents.replacingOccurrences(of: replacement.placeholder, with: text + replacement.placeholder)
        
        let writer = TemplateWriter(destination: self.folder)
        try writer.write(replaced, to: replacement.destinationPath, context: context, overwriteContents: true)
    }
    
    public func execute (specName: String? = nil, boneName: String, with json: JSON) throws {
        let context = BoneContext(json, environment: murrayFile.environment)
        guard let spec = specs
            .first(where: {
                if let specName = specName {
                    return $0.key == specName && $0.value.object[boneName] != nil
                } else {
                    return $0.value.object[boneName] != nil
                }
            })?.value else {
                throw CustomError.boneGroupNotFound(name: boneName, spec: specName)
        }
        
        guard let group = spec.object[boneName] else {
            throw CustomError.boneGroupNotFound(name: boneName, spec: specName)
        }
        
        let items = try self.items(from: spec, group: group)
        
        try items.forEach { item in
            guard let folder = item.file.parent else { throw CustomError.generic }
            
            try pluginManager.execute(phase: .beforeItemReplace(item: item, context: context), from: self.folder)
            
            try item.object.paths.forEach({ (path) in
                try self.transform(path: path, sourceFolder: folder, with: context)
            })
            try item.object.replacements.forEach({ replacement in
                try self.replace(from: replacement, sourceFolder: folder, with: context)
            })
            
            try pluginManager.execute(phase: .afterItemReplace(item: item, context: context), from: self.folder)
        }
    }
}


