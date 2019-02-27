//
//  Bone+Pipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation
import Files
import ShellOut

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
                return try? f.subfolder(named: current)
            }
            Logger.log("SourcesFolder: \(sourcesFolder?.path ?? "unknown")", level: .verbose)
            guard let containingFolder = sourcesFolder else {
                throw Error.missingSubfolder("")
            }
            
            guard let finalFolder =
                bone.createSubfolder == false ? containingFolder :
                    (try? containingFolder.subfolder(named: name)) ?? (try? containingFolder.createSubfolder(named: name)) else {
                        throw Error.missingSubfolder(containingFolder.path + "/" + name)
            }
            Logger.log("Parsing \(bone.name) files", level: .verbose)
            
            try bone.files.forEach { path in
                Logger.log(templatesFolder.path + "/" + path, level: .verbose)
                
                guard let templateFile = try? templatesFolder.file(named: path) else {
                    throw Error.missingFile(templatesFolder.path + "/" + path)
                }
                Logger.log("Moving to destination", level: .verbose)
                guard let file = try? templateFile.copy(to: finalFolder) else {
                    throw Error.missingFile(finalFolder.path + "/" + templateFile.name)
                }
                Logger.log("Renaming", level: .verbose)
                try PluginManager.beforeReplace(context: pluginContext, file: file)
                let placeholder = bone.placeholder
                if placeholder.count > 0 {
                    if let filename = path.split(separator: "/").last {
                        let resolvedName = try FileTemplate(fileContents: bone.placeholderReplaceRule, context: ["name": name]).render()
                        
                        try file.rename(to: filename.replacingOccurrences(of: placeholder, with: resolvedName))
                    }
                    Logger.log("Reading file", level: .verbose)
                    let string = try file.readAsString()
                    let template = FileTemplate(fileContents: string, context: context)
                    let rendered = try template.render()
                    try file.write(string: rendered)
                }
                Logger.log("Current folder: \(fs.currentFolder.path)", level: .verbose)
                
                bone.otherFilesRules.forEach { rule in
                    Logger.log("Looking for file \(rule.filePath)", level: .verbose)
                    if let file = try? fs.currentFolder.file(atPath: rule.filePath),
                        let contents = try? file.readAsString(encoding: .utf8),
                        let resolved = try? FileTemplate(fileContents: rule.text, context: context).render(){
                        
                        let newContents = contents.replacingOccurrences(of: rule.placeholder, with: resolved + rule.placeholder)
                        try? file.write(string: newContents)
                        
                    } else {
                        Logger.log("Unable to read file \(rule.filePath), skipping", level: .verbose)
                    }
                }
                
               
                try PluginManager.afterReplace(context: pluginContext, file: file)

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
    }
}

