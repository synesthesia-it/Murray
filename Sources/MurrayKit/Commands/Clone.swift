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
    private let subfolderPath: String?

    init(repository: Repository,
         context: Parameters,
         folder: Folder,
         subfolderPath: String?) {
        self.repository = repository
        self.context = context
        self.folder = folder
        self.subfolderPath = subfolderPath
    }

    public init(folder: Folder,
                subfolderPath: String? = nil,
                git: String,
                context: Parameters) {
        self.init(repository: .init(at: git),
                  context: context,
                  folder: folder,
                  subfolderPath: subfolderPath)
    }

    public func run() throws {
        guard let projectName: String = context["name"] else {
            throw Errors.unknown
        }
        let pluginManager = PluginManager.shared

        let context: Template.Context = .init(context)
        Logger.log("Template context:\n\(context)\n")

        Logger.log("Cloning repository from \(repository) into \(Folder.temporary.path)",
                   level: .verbose)
        try? Folder.temporary.subfolder(named: projectName).delete()
        
        var temporaryProjectFolder = try clone(from: repository,
                  into: Folder.temporary,
                  projectName: projectName)
        
        Logger.log("Project cloned to \(temporaryProjectFolder.path)")
        
        Logger.log("Creating final project folder at \(folder.path)\(projectName)",
                   level: .verbose)

        let projectFolder = try folder.createSubfolderIfNeeded(withName: projectName)
        
        Logger.log("Moving contents from temporary folder")
        
        if let subfolderPath = subfolderPath {
            Logger.log("Looking for subfolder \(subfolderPath) in checked out folder \(temporaryProjectFolder.path)")
            try temporaryProjectFolder = temporaryProjectFolder.subfolder(at: subfolderPath)
        }
        
        try temporaryProjectFolder.moveContents(to: projectFolder, includeHidden: true)
        
        guard let skeleton = try? CodableFile<Skeleton>.init(in: projectFolder) else {
            throw Errors.noValidSkeletonFound("\(projectFolder.path)")
        }

        Logger.log("Deleting original git folder, if present",
                   level: .verbose)
        try? projectFolder.subfolder(named: ".git").delete()

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
                .forEach { file in
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
                       projectName: String) throws -> Folder {
        do {
            var command = "git clone --single-branch --depth 1 "
            if repository.version.isEmpty == false {
                command += "--branch \(repository.version) "
            }
           
            command += repository.repo + " " + folder.path + projectName
            Logger.log("Cloning - command: \(command)", level: .verbose)
            try Process().launchBash(with: command)
            let projectFolder = try folder.subfolder(named: projectName)
            return projectFolder
        } catch {
            Logger.log("\(error)", level: .verbose)
            switch error {
            case is Errors: throw error
            default: throw Errors.invalidGitRepository(repository.package)
            }
        }
    }
}
