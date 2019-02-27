//
//  Bone+Scaffold.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation
import Files
extension Bone {
    public static func newBone(listName: String = "Custom", name: String, files: [String]) throws {

        let fs = FileSystem()
        guard let bonesFolder = try? fs.currentFolder.createSubfolderIfNeeded(withName: murrayLocalTemplatesFolderName) else {
            throw Error.missingSubfolder(fs.currentFolder.path + "/" + murrayLocalTemplatesFolderName)
        }

        guard let listFolder = try? bonesFolder.createSubfolderIfNeeded(withName: listName) else {
            throw Error.missingSubfolder(bonesFolder.path + "/" + listName)
        }

        guard let spec = try? listFolder.createFileIfNeeded(withName: "Bonespec.json") else {
            throw Error.missingBonespec(listFolder.path)
        }
        let list: BoneSpec
        if let data = try? spec.read() {
            do {
                list = try JSONDecoder().decode(BoneSpec.self, from: data)
                list.bones.forEach { (key, value) in
                    value.name = key
                }
            } catch let error {
                //                print (error)
                //                throw Error.bonespecParsingError
                Logger.log(error.localizedDescription, level: .error)
                list = BoneSpec(name: listName)
            }
        } else {
            list = BoneSpec(name: listName)
        }

        let bone = BoneItem(name: name, files: files)
        if list.bones[name] != nil {
            throw Error.existingBone(name)
        }
        //        list.bones[name] = bone
        list.append(bone)
        guard let nameFolder = try? listFolder.createSubfolderIfNeeded(withName: name) else {
            throw Error.missingSubfolder(listFolder.path + "/" + name)
        }

        try files.forEach {
            try nameFolder.createFile(named: $0)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(list) else {
            
            throw Error.bonespecGeneration
        }

        guard let string = String(data: jsonData, encoding: .utf8) else {
            
            throw Error.bonespecGeneration
        }

        try spec.write(string: string)

    }
}
