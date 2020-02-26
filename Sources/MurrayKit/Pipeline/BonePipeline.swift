//
//  BonePipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files
import Gloss

public struct ObjectReference<T: Glossy> {
    public let file: File
    public var object: T

    public init (file: File, object: T?) throws {
        guard let object = object else {
            throw CustomError.generic
        }
        self.file = file
        self.object = object
    }

    public func save() throws {
        guard let json = object.toJSON() else { return }
         let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        try self.file.write(data)
    }
}

public struct ListObject {
    public let murrayFile: MurrayFile
    public let package: ObjectReference<BonePackage>
    public let procedure: BoneProcedure
}

public struct BonePipeline {

    public let murrayFile: MurrayFile
    
    public let packages: [String: ObjectReference<BonePackage>]
    let folder: Folder
    //    var tree: [TreeObject] = []
    public let pluginManager: PluginManager
    public init(folder: Folder, murrayFileName: String = "Murrayfile.json", pluginManager: PluginManager = .shared) throws {
        
        guard let file = try? folder.file(named: murrayFileName).decodable(MurrayFile.self),
            file.environment[file.mainPlaceholder ?? MurrayFile.defaultPlaceholder] == nil
            else {
                throw CustomError.invalidMurrayfile
        }
        
        self.pluginManager = pluginManager
        self.folder = folder
        self.murrayFile = file
        
        packages = try file.packages
            
            .reduce([:]) {
                var packages = $0
                let file = try folder.file(at: $1)
                guard let spec = try file.decodable(BonePackage.self)
                    else { throw CustomError.undecodable(file: file, type: BonePackage.self) }
                packages[spec.name] = try ObjectReference(file: file, object: spec)
                return packages
        }
    }
    
    public func list() -> [ListObject]{
        packages.values
            .flatMap { package in
                package.object.procedures.map { procedure in ListObject(murrayFile: murrayFile, package: package, procedure: procedure)}
        }
    }
    
    func items(from package: ObjectReference<BonePackage>, procedure: BoneProcedure) throws -> [ObjectReference<BoneItem>] {
        return try procedure.itemPaths
            .compactMap { try package.file.parent?.file(at: $0) }
            .map { try ObjectReference(file: $0, object: $0.decodable(BoneItem.self)) }
    }
    
    public func transform(path: BonePath,
                          customFileContents: String? = nil,
                          sourceFolder: Folder,
                          with context: BoneContext) throws {
        let relativePath = try path.from.resolved(with: context)
        if let subfolder = try? sourceFolder.subfolder(at: relativePath) {
            
            try subfolder.subfolders.forEach { f in
                let relative = f.path(relativeTo: sourceFolder)
                
                let destinationFolder = try path.to.resolved(with: context) + "/" + relative
                let newPath = BonePath(from: relative, to: destinationFolder)
                try self.transform(path: newPath, sourceFolder: sourceFolder, with: context)
            }
            try subfolder.files.forEach { f in
                let relative = f.path(relativeTo: sourceFolder)
                let destinationFile = try path.to.resolved(with: context) + "/" + f.name
                let newPath = BonePath(from: relative, to: destinationFile)
                try self.transform(path: newPath, sourceFolder: sourceFolder, with: context)
            }
            return
        }
        let reader = TemplateReader(source: sourceFolder)
        let contents = try (customFileContents ?? reader
            .file(from: path, context: context)
            .readAsString()
            .resolved(with: context))
        
        let writer = TemplateWriter(destination: self.folder)
        try writer.write(contents, to: path, context: context)
        
    }
    
    public func replace(from replacement: BoneReplacement,
                        customContents: String? = nil,
                        sourceFolder: Folder,
                        with context: BoneContext) throws {
        
        let reader = TemplateReader(source: self.folder)
        let contents = try reader
            .file(from: replacement.destinationPath, context: context)
            .readAsString()
        
        let text: String
        
        if let customContents = customContents {
            text = customContents
        }
        else if let source = replacement.sourcePath {
            
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
    
    public func check(item: BoneItem, against context: BoneContext) throws {
        try item.parameters
            .filter { $0.isRequired }
            .forEach {
                if context.context[$0.name] == nil {
                    throw CustomError.missingRequiredParameter(bone: item, parameter: $0)
                }
        }
    }
    public func execute (packageName: String? = nil, boneName: String, with json: JSON) throws {
        let context = BoneContext(json, environment: murrayFile.environment)
        guard let package = packages
            .first(where: {
                if let packageName = packageName {
                    return $0.key == packageName && $0.value.object[boneName] != nil
                } else {
                    return $0.value.object[boneName] != nil
                }
            })?.value else {
                throw CustomError.boneProcedureNotFound(name: boneName, package: packageName)
        }
        
        guard let procedure = package.object[boneName] else {
            throw CustomError.boneProcedureNotFound(name: boneName, package: packageName)
        }
        
        let items = try self.items(from: package, procedure: procedure)
        
        try items.forEach { item in
            guard let folder = item.file.parent else { throw CustomError.generic }
            
            try self.check(item: item.object, against: context)
            
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


