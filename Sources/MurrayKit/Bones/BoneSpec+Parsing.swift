//
//  BoneSpec+Parsing.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files

extension BoneSpec {
     static func parse(from folder: Folder) throws -> BoneSpec {
        Logger.log("Looking for Bonespec", level: .verbose)
        guard let spec = try? folder.file(named: "Bonespec.json") else {
            throw Bone.Error.missingBonespec
        }
        Logger.log("Reading Bonespec", level: .verbose)
        guard let data = try? spec.read() else {
            throw Bone.Error.missingBonespec
        }
        Logger.log("Parsing Bonespec", level: .verbose)

        do {
            let list = try JSONDecoder().decode(BoneSpec.self, from: data)
            list.bones.forEach { (key, value) in
                value.name = key
            }
            return list
        } catch let error {
            Logger.log(error.localizedDescription, level: .verbose)
            throw Bone.Error.bonespecParsingError
        }
    }
}
