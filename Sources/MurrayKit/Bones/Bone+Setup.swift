//
//  Bone+Setup.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files
import ShellOut

extension Bone {
    public static func setup() throws {
        let fs = FileSystem()

        guard let boneFileReference = try? fs.currentFolder.file(named: "Bonefile"),
            let contents = try? boneFileReference.readAsString()
            else {
                throw Bone.Error.missingBonefile
        }

        let boneFile = try BoneFile(fileContents: contents)
        Logger.log("Removing old setup", level: .verbose)
        try? FileManager.default.removeItem(atPath: murrayTemplatesFolderName)

        guard let folder = try? fs.createFolder(at: murrayTemplatesFolderName) else {
            throw Error.existingFolder
        }

        let fileManager = FileManager.default
        try boneFile.parts.forEach { part in
            //File manager path should always restored to its original value after execution.
            //This helps testing and doesn't allow any subsequent operation to depend upon directory switching
            let defaultFolder = fileManager.currentDirectoryPath
            defer {
                fileManager.changeCurrentDirectoryPath(defaultFolder)
            }
            fileManager.changeCurrentDirectoryPath(folder.path)
            Logger.log("Cloning bones app from \(part.url.absoluteString)", level: .normal)

            try DependencyManager.shared.cloneBones(from: part.url, branch: part.branch)
            guard let boneFolder = folder.subfolders.first else {
                throw Error.missingSubfolder
            }
            //try? folder.subfolders.first?.moveContents(to: folder)
            _ = try BoneSpec.parse(from: boneFolder)
        }
    }
}
