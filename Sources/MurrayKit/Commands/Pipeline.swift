//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
import Files

struct Pipeline {
    let murrayfile: CodableFile<Murrayfile>
    let procedures: [PackagedProcedure]
    let context: Template.Context
    
    init(murrayfile: CodableFile<Murrayfile>,
         procedure: PackagedProcedure,
         context: Parameters) throws {
        try self.init(murrayfile: murrayfile, procedures: [procedure], context: context)
    }
    
    init(murrayfile: CodableFile<Murrayfile>,
         procedures: [PackagedProcedure],
         context: Parameters) throws {
        self.murrayfile = murrayfile
        self.procedures = procedures
        self.context = Template.Context(context, environment: murrayfile.object.environment)
    }
    
    init(murrayfile: CodableFile<Murrayfile>,
         procedure procedureName: String,
         context: Parameters) throws {
        try self.init(murrayfile: murrayfile, procedures: [procedureName], context: context)
    }
    
    init(murrayfile: CodableFile<Murrayfile>,
         procedures procedureNames: [String],
         context: Parameters) throws {
        self.murrayfile = murrayfile
        
        let packages = try murrayfile.packages()
        self.procedures = try procedureNames.map { procedureName in
            guard let procedure = packages
                .compactMap({ try? PackagedProcedure(package: $0, procedureName: procedureName) })
                .first else {
                throw Errors.procedureNotFound(name: procedureName)
            }
            return procedure
        }
        
        self.context = Template.Context(context, environment: murrayfile.object.environment)
    }
    
    func item(at path: String, in procedure: PackagedProcedure) throws -> CodableFile<Item> {
        guard let file = try procedure.package.file.parent?.file(at: path) else {
            throw Errors.unparsableFile(path)
        }
        return try CodableFile<Item>(file: file)
    }
    
    func run() throws {
        try writeableFiles().forEach {
            try $0.commit()
        }
    }
    
    func writeableFiles() throws -> [WriteableFile] {
        try procedures.flatMap { try writeableFiles(for: $0) }
    }
    
    private func rootFolder() -> Folder {
        murrayfile.file.parent!
    }
    
    private func writeableFiles(for procedure: PackagedProcedure) throws -> [WriteableFile] {
        let items = try procedure.procedure.itemPaths.map {
            try self.item(at: $0, in: procedure)
        }
        
        return try items.flatMap { try writeableFiles(for: $0) }
    }
    private func writeableFiles(for item: CodableFile<Item>) throws -> [WriteableFile] {
        
        let paths = try item.object.paths.flatMap {
            try writeableFiles(for: $0, item: item)
        }
        
        let replacements = try item.object.replacements.map {
            try writeableFile(for: $0, item: item)
        }
        
        return paths + replacements
    }
    
    private func writeableFiles(in folder: Folder, destinationPath: String) throws -> [WriteableFile] {
        
        let files = try folder.files.map { file -> WriteableFile in
            let destinationName = try file.name.resolve(with: context)
            let path = destinationPath.appendingPathComponent(destinationName)
            return WriteableFile(content: .file(file),
                                 path: path,
                                 destinationRoot: rootFolder(),
                                 action: .create(context: context))
        }
        let subfolders = try folder.subfolders.flatMap { subfolder in
            try writeableFiles(in: subfolder,
                               destinationPath: destinationPath.appendingPathComponent(subfolder.name))
        }
        return files + subfolders
    }
    
    private func writeableFiles(for path: Item.Path, item: CodableFile<Item>) throws -> [WriteableFile] {
        
        let sourcePath = try path.from.resolve(with: context)
        
        if let folder = try? item.file.parent?.subfolder(at: sourcePath) {
            return try writeableFiles(in: folder, destinationPath: path.to)
        }
        
        guard let file = try item.file.parent?.file(at: sourcePath) else {
            throw Errors.unparsableFile(sourcePath)
        }
        
        return [WriteableFile(content: .file(file),
                              path: path.to,
                              destinationRoot: rootFolder(),
                              action: .create(context: context))]
    }
    
    private func writeableFile(for replacement: Item.Replacement, item: CodableFile<Item>) throws -> WriteableFile {
        
        let content: Content
        
        if let text = replacement.text {
            content = .text(text)
        } else if let sourcePath = replacement.source {
            guard let file = try item.file.parent?.file(at: sourcePath) else {
                throw Errors.unparsableFile(sourcePath)
            }
            content = .file(file)
        } else {
            // this should never happen - replacements always have either a text or a source.
            throw Errors.unknown
        }
        
        return WriteableFile(content: content,
                             path: replacement.destination,
                             destinationRoot: rootFolder(),
                             action: .edit(context: context,
                                           placeholder: replacement.placeholder))
    }
    
}
