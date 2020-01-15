//
//  Utilities.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files
import Quick
import Gloss
import MurrayKit

public struct ConcreteFile {
    public let contents: String
    public let folder: Folder
    public let path: BonePath
    public init(contents: String, folder: Folder, path: BonePath) {
        self.contents = contents
        self.folder = folder
        self.path = path
    }
    public func resolved(with context:BoneContext) -> String {
        return try! contents.resolved(with: context)
    }
    @discardableResult
    public func createSource() -> File {
        let relativePath =  path.from
        return try! folder.createFileWithIntermediateFolders(at: relativePath, contents: contents.data(using: .utf8) ?? Data())
    }
    
    @discardableResult
    public func createDestination(with context:BoneContext) -> File {
        let relativePath = try! path.to.resolved(with: context)
        return try! folder.createFileWithIntermediateFolders(at: relativePath, contents: resolved(with: context).data(using: .utf8) ?? Data())
      }
}

public extension QuickSpec {
    func tempFolder(for subfolder: String) -> Folder {
        
        let root = try! Folder.temporary
        .createSubfolderIfNeeded(withName: "Murray")
        //.createSubfolderIfNeeded(withName: "BoneWriter")
        let folder = subfolder
            .components(separatedBy: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
            .filter { !$0.isEmpty }
            .reduce(root) {
            try! $0.createSubfolderIfNeeded(withName: $1)
        }
        try! folder.empty()
        print("Running in: \(folder)")
        return folder
    }
}
public extension JSON {
    static func from(_ string: String) -> JSON {
        return try! JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: []) as! JSON
    }
}
