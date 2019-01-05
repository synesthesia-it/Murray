//
//  Bone+List.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation
import Files

extension Bone {
    static func remoteBones() throws -> [BoneSpec] {
        let fs = FileSystem()
        guard let bonesFolder = try? fs.currentFolder.subfolder(named: murrayTemplatesFolderName) else {
            throw Error.missingSetup
        }
        return try bonesFolder.subfolders.map { boneFolder in
            return try BoneSpec.parse(from: boneFolder)
        }
    }

    static func localBones() throws -> [BoneSpec]? {
        let fs = FileSystem()
        guard let bonesFolder = try? fs.currentFolder.subfolder(named: murrayLocalTemplatesFolderName) else {
            return nil
        }
        return try bonesFolder.subfolders.map { boneFolder in
            let spec = try BoneSpec.parse(from: boneFolder)
            spec.isLocal = true
            return spec
        }
    }
    static func bones() throws -> [BoneSpec] {
        return try remoteBones() + (localBones() ?? [])
    }
    public static func list() throws -> [String] {
        return try self.bones()
            .map { $0.printableDescription }
    }
}
