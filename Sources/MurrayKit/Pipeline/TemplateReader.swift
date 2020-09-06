//
//  BoneReader.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Files
import Foundation
import Gloss
public class TemplateReader {
    public let source: Folder

    public init(source: Folder) {
        self.source = source
    }

    public func file(from path: String, context: BoneContext) throws -> File {
        let relativePath = try path.resolved(with: context)
        return try source.file(at: relativePath)
    }

    public func file(from path: BonePath, context: BoneContext) throws -> File {
        let relativePath = try path.from.resolved(with: context)
        return try source.file(at: relativePath)
    }

    public func string(from path: BonePath, context: BoneContext) throws -> String {
        return try string(from: path.from, context: context)
    }

    public func string(from path: String, context: BoneContext) throws -> String {
        return try file(from: path, context: context).readAsString(encodedAs: .utf8)
    }

//    public func decodable<T: JSONDecodable>(from path: BonePath, context: BoneContext, type: T.Type) throws -> T? {
//        return try file(from: path, context: context).decodable(type)
//    }
}
