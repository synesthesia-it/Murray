//
//  BoneReader.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Files
import Foundation

public class TemplateWriter {
    let destination: Folder

    public init(destination: Folder) {
        self.destination = destination
    }

    @discardableResult
    public func write(_ contents: String, to path: String, context: BoneContext, overwriteContents: Bool = false) throws -> File {
        guard let data = try contents.resolved(with: context).data(using: .utf8) else {
            throw CustomError.generic
        }
        return try write(data, to: path, context: context, overwriteContents: overwriteContents)
    }

    @discardableResult
    public func write(_ contents: String, to path: BonePath, context: BoneContext, overwriteContents: Bool = false) throws -> File {
        try write(contents, to: path.to, context: context, overwriteContents: overwriteContents)
    }

    @discardableResult
    public func write(_ contents: Data, to path: BonePath, context: BoneContext, overwriteContents: Bool = false) throws -> File {
        return try write(contents, to: path.to, context: context, overwriteContents: overwriteContents)
    }

    @discardableResult
    public func write(_ contents: Data, to path: String, context: BoneContext, overwriteContents: Bool = false) throws -> File {
        let relativePath = try path.resolved(with: context)

        return try destination.createFileWithIntermediateFolders(at: relativePath, contents: contents, overwriteContents: overwriteContents)
    }
}
