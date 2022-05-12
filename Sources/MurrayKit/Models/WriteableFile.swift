//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
import Files

public struct WriteableFile {
    
    public enum Action {
        case create(context: Template.Context)
        case edit(context: Template.Context, placeholder: String)
    }
    
    public let content: Content
    public let path: String
    public let root: Folder
    public let action: Action
    
    public init(content: Content,
                path: String,
                destinationRoot: Folder,
                action: Action) {
        self.content = content
        self.path = path
        self.root = destinationRoot
        self.action = action
    }
    
    public func preview() throws -> String {
        switch action {
        case .create(let context):
            return try resolve(with: context)
        case .edit(let context, let placeholder):
            return try replace(searching: placeholder, with: context)
        }
    }
    
    @discardableResult
    public func commit() throws -> File {
        switch action {
        case .create(let context):
            return try create(with: context)
        case .edit(let context, let placeholder):
            return try update(searching: placeholder, with: context)
        }
    }
    
    private func create(with context: Template.Context) throws -> File {
        let destination = try root.createFileIfNeeded(at: path.resolve(with: context))
        let contents = try resolve(with: context)
        try destination.write(contents)
        return destination
    }
    
    private func update(searching placeholder: String,
                        with context: Template.Context) throws -> File {
        let destination = try root.file(at: path.resolve(with: context))
        let contents = try replace(searching: placeholder, with: context)
        try destination.write(contents)
        return destination
    }
    
    private func replace(searching placeholder: String,
                         with context: Template.Context) throws -> String {
        let destination = try root.file(at: path.resolve(with: context))
        let replacement = try content.resolve(with: context) + placeholder
        return try destination.readAsString()
            .replacingOccurrences(of: placeholder.resolve(with: context),
                                  with: replacement)
        
    }
}

extension WriteableFile: Resolvable {
    public func resolve(with context: Template.Context) throws -> String {
        try content.resolve(with: context)
    }
    
}
