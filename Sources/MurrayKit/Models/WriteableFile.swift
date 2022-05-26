//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public struct WriteableFile {
    
    public enum Action {
        case create//(context: Template.Context)
        case edit(placeholder: String)
    }
    
    public let identifier = UUID()
    public let content: Content
    public let path: String
    public let root: Folder
    public let action: Action
    let reference: Any?
    public init(content: Content,
                path: String,
                destinationRoot: Folder,
                action: Action,
                reference: Any? = nil) {
        self.content = content
        self.path = path
        self.root = destinationRoot
        self.action = action
        self.reference = reference
    }
    
    public func preview(context: Template.Context) throws -> String {
        switch action {
        case .create:
            try Logger.log("File will be created at \(path.resolve(with: context))\n",
                       level: .normal)
            return try resolve(with: context)
        case .edit(let placeholder):
            try Logger.log("Contents of file at \(path.resolve(with: context)) will be replaced when placeholder: '\(placeholder)' is found",
                       level: .normal)
            return try replace(searching: placeholder, with: context)
        }
    }
    
    @discardableResult
    public func commit(context: Template.Context) throws -> File {
        switch action {
        case .create:
            try Logger.log("Will create file at \(path.resolve(with: context))\n",
                       level: .normal)
            return try create(with: context)
        case .edit(let placeholder):
            try Logger.log("Will replace contents of file at \(path.resolve(with: context)), looking for placeholder: '\(placeholder)'",
                       level: .normal)
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
    
    public func enrichedContext(from originalContext: Template.Context) -> Template.Context {
        
        let fileContext: JSON = ["_destinationPath": root.path.appendingPathComponent(path),
                                 "_destinationRoot": root.path,
                                 "_destinationFilename": path.components(separatedBy: "/").last]
        
        return originalContext.adding(fileContext)
    }
}

extension WriteableFile: Resolvable {
    public func resolve(with context: Template.Context) throws -> String {
        try content.resolve(with: context)
    }
    
}
