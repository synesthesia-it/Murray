//
//  BoneReader.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files

public extension Folder {
    func createFileWithIntermediateFolders(at path: String, contents: Data) throws -> File {
        let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
        let subfolders = components.dropLast()
        
        guard let filename = components.last else {
            //filename not found. exit.
            throw MurrayKit.Error.generic
        }
            
        var folder = self
        
        try subfolders.forEach {
            folder = try folder.createSubfolderIfNeeded(withName: $0)
        }
        
        if folder.containsFile(named: filename) {
            //File already exist. exit
            throw MurrayKit.Error.generic
        }
        return try folder.createFile(named: filename, contents: contents)
    }
}

public class BoneWriter {
    
    let destination: Folder
    
    public init(destination: Folder) {
        self.destination = destination
    }
    public func write(_ contents: String, to path: BonePath, context: BoneContext) throws -> File {
        guard let data = try contents.resolved(with: context).data(using: .utf8) else {
            throw Error.generic
        }
        return try write(data, to: path, context: context)
    }
    public func write(_ contents: Data, to path: BonePath, context: BoneContext) throws -> File {
        let relativePath = try path.to.resolved(with: context)
        
        return try destination.createFileWithIntermediateFolders(at: relativePath, contents: contents)
    
    }
}
