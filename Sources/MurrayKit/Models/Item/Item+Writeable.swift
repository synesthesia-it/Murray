//
//  File.swift
//  
//
//  Created by Stefano Mondino on 14/05/22.
//

import Foundation


extension CodableFile where Object == Item {
    public func writeableFiles(context: Template.Context,
                               destinationRoot: Folder) throws -> [WriteableFile] {
        
        let paths = try object.paths.flatMap {
            try writeableFiles(for: $0,
                               context: context,
                               destinationRoot: destinationRoot)
        }
        
        let replacements = try object.replacements.map {
            try writeableFile(for: $0, context: context, destinationRoot: destinationRoot)
        }
        
        return paths + replacements
    }
    
    public func writeableFiles(for path: Item.Path,
                                context: Template.Context,
                                destinationRoot: Folder) throws -> [WriteableFile] {
        
        let sourcePath = try path.from.resolve(with: context)
        
        if let folder = try? file.parent?.subfolder(at: sourcePath) {
            return try writeableFiles(in: folder,
                                      context: context,
                                      destinationRoot: destinationRoot,
                                      destinationPath: path.to)
        }
        
        guard let file = try file.parent?.file(at: sourcePath) else {
            throw Errors.unparsableFile(sourcePath)
        }
        
        return [WriteableFile(content: .file(file),
                              path: path.to,
                              destinationRoot: destinationRoot,
                              action: .create,
                              reference: path)]
    }
    
    private func writeableFiles(in folder: Folder,
                                context: Template.Context,
                                destinationRoot: Folder,
                                destinationPath: String) throws -> [WriteableFile] {
        
        let files = try folder.files.map { file -> WriteableFile in
            let destinationName = try file.name.resolve(with: context)
            let path = destinationPath.appendingPathComponent(destinationName)
            return WriteableFile(content: .file(file),
                                 path: path,
                                 destinationRoot: destinationRoot,
                                 action: .create,
                                 reference: Item.Path(from: file.path, to: path))
        }
        let subfolders = try folder.subfolders.flatMap { subfolder in
            try writeableFiles(in: subfolder,
                               context: context,
                               destinationRoot: destinationRoot,
                               destinationPath: destinationPath.appendingPathComponent(subfolder.name))
        }
        return files + subfolders
    }
    

    
    public func writeableFile(for replacement: Item.Replacement,
                               context: Template.Context,
                               destinationRoot: Folder) throws -> WriteableFile {
        
        let content: Content
        
        if let text = replacement.text {
            content = .text(text)
        } else if let sourcePath = replacement.source {
            guard let file = try file.parent?.file(at: sourcePath) else {
                throw Errors.unparsableFile(sourcePath)
            }
            content = .file(file)
        } else {
            // this should never happen - replacements always have either a text or a source.
            throw Errors.unknown
        }
        
        return WriteableFile(content: content,
                             path: replacement.destination,
                             destinationRoot: destinationRoot,
                             action: .edit(placeholder: replacement.placeholder),
                             reference: replacement)
    }
    
}

