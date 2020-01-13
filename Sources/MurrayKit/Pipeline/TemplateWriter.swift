//
//  BoneReader.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files


public class TemplateWriter {
    
    let destination: Folder
    
    public init(destination: Folder) {
        self.destination = destination
    }
    
    @discardableResult
    public func write(_ contents: String, to path: BonePath, context: BoneContext) throws -> File {
        guard let data = try contents.resolved(with: context).data(using: .utf8) else {
            throw CustomError.generic
        }
        return try write(data, to: path, context: context)
    }
    
    @discardableResult
    public func write(_ contents: Data, to path: BonePath, context: BoneContext) throws -> File {
        let relativePath = try path.to.resolved(with: context)
        
        return try destination.createFileWithIntermediateFolders(at: relativePath, contents: contents)
    
    }
}
