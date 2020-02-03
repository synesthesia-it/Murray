//
//  BonePipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files
import ShellOut

public struct SkeletonPipeline {
    
    

    let folder: Folder
//    var tree: [TreeObject] = []
    let pluginManager: PluginManager
    let projectName: String
    public init(folder: Folder, projectName: String,pluginManager: PluginManager = .shared) throws {
        self.projectName = projectName
        self.pluginManager = pluginManager
        self.folder = folder
        
    }
    
    public func execute (projectPath: String, with json: JSON) throws {
        let context = BoneContext(json, environment: [MurrayFile.defaultPlaceholder: projectName])
        if let skeletonFolder = try? Folder(path: projectPath) {
            let newFolder = try skeletonFolder.copy(to: folder)
            try newFolder.rename(to: projectName)
            
        } else {
        let repository = Repository(package: projectPath)
        try self.clone(from: repository, into: folder, projectName: projectName)
        }
        
        let projectFolder = try folder.subfolder(named: projectName)
        let skeletonSpec = try projectFolder.decodable(SkeletonSpec.self, at: "Skeletonspec.json")
        
        try skeletonSpec?.files.forEach { path in
            let source = try projectFolder.file(at: path.from.resolved(with: context))
            _ = try projectFolder.createFile(at: path.to.resolved(with: context),contents: source.read())
        }
        
        try skeletonSpec?.folders.forEach { folder in
            let source = try projectFolder.subfolder(at: folder.from.resolved(with: context))
            let destination = try projectFolder.createSubfolder(at: folder.to.resolved(with: context))
            try source.moveContents(to: destination)
            try source.delete()
        }
        
        try skeletonSpec?.scripts.forEach {
            try shellOut(to: $0.resolved(with: context), at: projectFolder.path)
        }
        try? projectFolder.file(at: "Skeletonspec.json").delete()
    }
    
    private func clone(from repository: Repository, into folder: Folder, projectName: String) throws {
        
        var command = "git clone --single-branch "
        if repository.version.isEmpty == false {
            command += "--branch \(repository.version) "
        }
        command += repository.repo + " " + folder.path + projectName
        Logger.log("Cloning - command: \(command)")
        try shellOut(to: command)
    }
}



