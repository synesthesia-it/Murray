//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
import Files

struct WriteableFile {
    
    let content: Content
    let path: String
    let root: Folder
    
    init(content: Content,
         path: String,
         root: Folder) {
        self.content = content
        self.path = path
        self.root = root
    }
    
    func create(with context: Template.Context) throws -> File {
        let destination = try root.createFileIfNeeded(at: path.resolve(with: context))
        let contents = try resolve(with: context)
        try destination.write(contents)
        return destination
    }
    
    
    func update(searching placeholder: String,
                with context: Template.Context) throws -> File {
        let destination = try root.file(at: path.resolve(with: context))
        let contents = try replace(searching: placeholder, with: context)
        try destination.write(contents)
        return destination
    }
}

extension WriteableFile: Resolvable {
    func resolve(with context: Template.Context) throws -> String {
        try content.resolve(with: context)
    }
    func replace(searching placeholder: String,
                 with context: Template.Context) throws -> String {
        let destination = try root.file(at: path.resolve(with: context))
        let replacement = try content.resolve(with: context) + placeholder
        return try destination.readAsString()
            .replacingOccurrences(of: placeholder.resolve(with: context),
                                  with: replacement)
        
    }
}

