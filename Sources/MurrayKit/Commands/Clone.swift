//
//  File.swift
//  
//
//  Created by Stefano Mondino on 26/07/22.
//

import Foundation

public struct Clone {
    
    private let repository: Repository
    private let context: Parameters
    private let folder: Folder
    
    init(repository: Repository, context: Parameters, folder: Folder) {
        self.repository = repository
        self.context = context
        self.folder = folder
    }
    
    public init(folder: Folder,
                git: String,
                context: Parameters) {
        self.init(repository: .init(at: git),
                  context: context,
                  folder: folder)
    }
    
    public func run() throws {
        guard let projectName: String = context["name"] else {
            throw Errors.unknown
        }
        let pluginManager = PluginManager.shared
        
        let context: Template.Context = .init(context)
        Logger.log("Template context:\n\(context)\n")
        
        Logger.log("Cloning repository from \(repository) into \(folder.path)",
                   level: .verbose)
        
        try clone(from: repository, into: folder, projectName: projectName)
        
        Logger.log("Looking for project folder at \(folder.path)\(projectName)",
                   level: .verbose)
        
        let projectFolder = try folder.subfolder(named: projectName)
        
        guard let skeleton = try? CodableFile<Skeleton>.init(in: projectFolder) else {
            throw Errors.noValidSkeletonFound("\(projectFolder.path)")
        }
        
        Logger.log("Deleting original git folder",
                   level: .verbose)
        try projectFolder.subfolder(named: ".git").delete()
        
        Logger.log("Resolving paths",
                   level: .verbose)
        
        try skeleton.object.paths.forEach { path in
            let enrichedContext = context.adding(path.customParameters())
            try pluginManager.execute(.init(element: path,
                                      context: enrichedContext,
                                      phase: .before,
                                      root: projectFolder))

            try skeleton.writeableFiles(for: path,
                                        resolveSource: false,
                                        context: context,
                                        destinationRoot: projectFolder)
            .forEach {  file in
                try file.commit(context: context)
            }
            try pluginManager.execute(.init(element: path,
                                      context: enrichedContext,
                                      phase: .after,
                                      root: projectFolder))
        }
        Logger.log("Deleting original paths",
                   level: .verbose)
        skeleton.object.paths
            .map { $0.from }
            .forEach {
                Logger.log("Deleting \($0)",
                           level: .verbose)
                try? projectFolder.file(at: $0).delete()
                try? projectFolder.subfolder(at: $0).delete()
        }
        Logger.log("Launching custom scripts",
                   level: .verbose)
        try skeleton.object.scripts.forEach {
            let script = try $0.resolve(with: context)
            Logger.log("\(script)",
                       level: .verbose)
            try Process().launchBash(with: script, in: projectFolder)
        }
        
        if skeleton.object.initializeGit {
            Logger.log("Initializing git version control",
                       level: .verbose)
            try Process().launchBash(with: "git init", in: projectFolder)
        }
        
        Logger.log("Deleting skeleton file at \(skeleton.file.path(relativeTo: folder))",
                   level: .verbose)
        try skeleton.file.delete()
        Logger.log("Created new project named \(projectName) at \(projectFolder.path)")
    }
    
    private func clone(from repository: Repository,
                       into folder: Folder,
                       projectName: String) throws {
        do {
            var command = "git clone --single-branch "
            if repository.version.isEmpty == false {
                command += "--branch \(repository.version) "
            }
            command += repository.repo + " " + folder.path + projectName
            Logger.log("Cloning - command: \(command)")
            try Process().launchBash(with: command)
        } catch let error {
            Logger.log("\(error)", level: .verbose)
            throw Errors.invalidGitRepository(repository.package)
        }
    }
}
