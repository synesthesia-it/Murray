//
//  Bone+Pipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation
import Files
import ShellOut

public extension BoneItem {
     func files(from folder: Folder) throws -> [File] {
        return try files.map { path in
            Logger.log(folder.path + "/" + path, level: .verbose)
            
            guard let templateFile = try? folder.file(named: path) else {
                throw Bone.Error.missingFile(folder.path + "/" + path)
            }
            return templateFile
        }
        
    }
    
    func resolve(file: File, context: [String: Any]) throws -> String {
        let string = try file.readAsString()
        return try resolve(fileContents: string, context: context)
    }
     func resolve(fileContents string: String, context: [String: Any]) throws -> String {
        let template = FileTemplate(fileContents: string, context: context)
        return try template.render()
    }
}

extension Bone {

    public func run() throws {
        let fs = FileSystem()
        
        guard var bonesFolder = try? fs.currentFolder.subfolder(named: Bone.murrayTemplatesFolderName) else {
            throw Error.missingSetup
        }

        
        let lists = try Bone.bones()
        
        let tuples:[(list: BoneSpec, bone: BoneItem)] = lists
            .filter { self.listName.count == 0 || $0.name == self.listName }
            .compactMap { list in
                if let rootBone = list.bones[self.boneName] {
                    return (list, rootBone)
                } else {
                    return nil
                }
        }
        guard let root = tuples.first else {
            throw Error.unknownBone(self.boneName)
        }
        if tuples.count != 1 {
            throw Error.multipleBones(self.boneName, tuples)
        }
        //            .reduce(nil) { acc, list in
        //                if acc != nil { return acc }
        //                if let rootBone = list.bones[boneName] {
        //                    return (list, rootBone)
        //                } else {
        //                    return nil
        //                }
        //        }
        
        let boneList = root.list
        let rootBone = root.bone
        
        if boneList.isLocal {
            guard let localFolder = try? fs.currentFolder.subfolder(named: Bone.murrayLocalTemplatesFolderName) else {
                throw Error.missingLocalSubfolder(fs.currentFolder.path + "/" + Bone.murrayLocalTemplatesFolderName)
            }
            bonesFolder = localFolder
        }
        
        Logger.log(bonesFolder.path, level: .verbose)
        guard
            let templatesFolder = try? bonesFolder.subfolder(named: boneList.name).subfolder(atPath: boneList.sourcesBaseFolder) else {
                throw Error.missingSubfolder(bonesFolder.path + "/" + boneList.name + "/" + boneList.sourcesBaseFolder)
        }
        
        var context: [String: Any] = self.context
        //TODO convert inputstring into dictionary
        if let skeleton = try? SkeletonSpec.parse(from: fs.currentFolder) {
            skeleton.environmentPlaceholders?.forEach {
                if context[$0.key] == nil {
                    context [$0.key] = $0.value
                }
            }
        }
        let pluginContext = BonePluginContext(boneSpec: boneList, currentBone: nil, name: name, context: context )
        try PluginManager.initializeBones(context: pluginContext)
        try self.createSubBone(boneList: boneList, bone: rootBone, templatesFolder: templatesFolder, name: name, fs: fs, context: context)
        try PluginManager.finalizeBones(context: pluginContext)
    }
    
    private func createSubBone(boneList: BoneSpec, bone: BoneItem, templatesFolder: Folder, name: String, fs: FileSystem, context: [String: Any]) throws {
        var context = context
        context["name"] = context["name"] ?? name
        let pluginContext = BonePluginContext(boneSpec: boneList, currentBone: bone, name: name, context: context )
        Logger.log("Starting \(bone.name) bone", level: .verbose)
       
        if bone.files.count > 0 {
            
            let subfolders = boneList.folders + bone.folders
            Logger.log("Subfolders: \(subfolders)", level: .verbose)
            let sourcesFolder: Folder? = subfolders.reduce(fs.currentFolder) { acc, current -> Folder? in
                guard let f = acc else { return nil }
                return (try? f.subfolder(named: current)) ?? (try? f.createSubfolder(named: current))
            }
            Logger.log("SourcesFolder: \(sourcesFolder?.path ?? "unknown")", level: .verbose)
            guard let containingFolder = sourcesFolder else {
                throw Error.missingSubfolder("")
            }
            
            var finalFolderName = try bone.folderName.resolved(with: context)
            guard let finalFolder =
                bone.createSubfolder == false ? containingFolder :
                    (try? containingFolder.subfolder(named: finalFolderName)) ?? (try? containingFolder.createSubfolder(named: finalFolderName)) else {
                        throw Error.missingSubfolder(containingFolder.path + "/" + finalFolderName)
            }
            Logger.log("Parsing \(bone.name) files", level: .verbose)
            
            try bone.files(from: templatesFolder).forEach { templateFile in
                
                Logger.log("Moving to destination", level: .verbose)
//                guard let file = try? templateFile.copy(to: finalFolder) else {
//                    do  {
//                        _ = try templateFile.readAsString(encoding: .utf8)
//                    }
//                    catch {
//                        throw Error.missingFile(templateFile.path)
//                    }
//                    throw Error.existingFile(finalFolder.path + "/" + templateFile.name)
//                }
                
                
                Logger.log("Renaming", level: .verbose)
                //try PluginManager.beforeReplace(context: pluginContext, file: file)
                let placeholder = bone.placeholder
                if placeholder.count > 0 {
                    if let filename = templateFile.path.split(separator: "/").last {
                        let resolvedName = try FileTemplate(fileContents: bone.placeholderReplaceRule, context: context ).render()
                        let newFilename = filename.replacingOccurrences(of: placeholder, with: resolvedName)
                        
                    
                    Logger.log("Reading file", level: .verbose)
                    let rendered = try bone.resolve(file: templateFile, context: context)
//                    let rendered = try bone.resolve(file: file, context: context)
                        if finalFolder.containsFile(named: newFilename) {
                            throw Error.existingFile(finalFolder.path + "" + newFilename)
                        }
                        guard let file = try? finalFolder.createFile(named: newFilename) else {
                            throw Error.existingFile(finalFolder.path + "" + newFilename)
                        }
                    
                    try file.write(string: rendered)
                    Logger.log("Current folder: \(fs.currentFolder.path)", level: .verbose)
                        
                    try PluginManager.afterReplace(context: pluginContext, file: file)
                    }
                }
            }
        }
        bone.otherFilesRules.forEach { rule in
            Logger.log("Looking for file \(rule.filePath)", level: .verbose)
            let text: String
            if let path = rule.fileTemplate {
                if let file = try? templatesFolder.file(atPath: path),
                    let contents = try? file.readAsString(encoding: .utf8) {
                    text = contents
                } else {
                     Logger.log("Unable to read file \(path), skipping", level: .verbose)
                    return
                }
            } else {
                text = rule.text
            }
            guard let resolvedPath = try? FileTemplate(fileContents: rule.filePath, context: context).render() else {
                Logger.log("Unable to read file \(rule.filePath), skipping", level: .verbose)
                return
            }
            if let file = try? fs.currentFolder.file(atPath: resolvedPath),
                let contents = try? file.readAsString(encoding: .utf8),
                let resolved = try? FileTemplate(fileContents: text, context: context).render(){
                
                let newContents = contents.replacingOccurrences(of: rule.placeholder, with: resolved + rule.placeholder)
                try? file.write(string: newContents)
                
            } else {
                Logger.log("Unable to read file \(rule.filePath), skipping", level: .verbose)
            }
        }
        Logger.log("Parsing \(bone.name) subBones", level: .verbose)
        try bone.subBones
            .filter { bone.name != $0 }
            .compactMap {
                boneList.bones[$0]
            }.forEach {
                try self.createSubBone(boneList: boneList, bone: $0, templatesFolder: templatesFolder, name: name, fs: fs, context: context)
        }
        if bone.scripts.count > 0 {
            try shellOut(to: bone.scripts)
        }
    }
}

