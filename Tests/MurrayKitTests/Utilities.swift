//
//  Utilities.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files
import Quick
@testable import MurrayKit

struct ConcreteBoneItem {
    let contents: String
    let folder: Folder
    let path: BonePath

    func resolved(with context:BoneContext) -> String {
        return try! contents.resolved(with: context)
    }
    @discardableResult
    func createSource() -> File {
        let relativePath =  path.from
        return try! folder.createFileWithIntermediateFolders(at: relativePath, contents: contents.data(using: .utf8) ?? Data())
    }
    
    @discardableResult
    func createDestination(with context:BoneContext) -> File {
        let relativePath = try! path.to.resolved(with: context)
        return try! folder.createFileWithIntermediateFolders(at: relativePath, contents: resolved(with: context).data(using: .utf8) ?? Data())
      }
}

extension QuickSpec {
    func tempFolder(for subfolder: String) -> Folder {
        let root = try! FileSystem().temporaryFolder
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
