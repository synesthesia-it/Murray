//
//  File.swift
//
//
//  Created by Stefano Mondino on 26/07/22.
//

import Foundation

public struct Clone: CommandWithContext {
    public let mainPlaceholder: String
//    public let repository: Repository
    public let path: String
    public let forceLocalCopy: Bool
    public let params: [String]
    public let folder: Folder
    public let subfolderPath: String?

    public init(path: String,
                folder: Folder,
                subfolderPath: String? = nil,
                mainPlaceholder: String,
                copyFromLocalFolder: Bool = false,
                parameters: [String]? = nil) {
        self.path = path
        self.folder = folder
        self.subfolderPath = subfolderPath
        self.mainPlaceholder = mainPlaceholder
        params = parameters ?? []
        forceLocalCopy = copyFromLocalFolder
    }

    public func execute() throws {
        let context: Template.Context = .init(context(mainPlaceholderKey: "name"))
        guard let projectName: String = context.values["name"] as? String else {
            throw Errors.unknown
        }

        Logger.log("Template context:\n\(context)\n")

        try? Folder.temporary.subfolder(named: projectName).delete()
        var temporaryProjectFolder: Folder
        if forceLocalCopy {
            Logger.log("Copying contents from: \(path)")
            let destination = try Folder.temporary.createSubfolderIfNeeded(withName: projectName)
            let copySource = try Folder(path: path)
            temporaryProjectFolder = try copySource.copy(to: destination)
        } else {
            let repository = Repository(at: path)
            Logger.log("Cloning repository from \(repository) into \(Folder.temporary.path)",
                       level: .verbose)
            temporaryProjectFolder = try clone(from: repository,
                                               into: Folder.temporary,
                                               projectName: projectName)

            Logger.log("Project cloned to \(temporaryProjectFolder.path)")
        }
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

        try resolvePaths(for: skeleton,
                         projectFolder: projectFolder,
                         context: context)

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

    private func resolvePaths(for skeleton: CodableFile<Skeleton>,
                              projectFolder: Folder,
                              context: Template.Context) throws {
        Logger.log("Resolving paths",
                   level: .verbose)
        let pluginManager = PluginManager.shared
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
            .filter { $0.from != ((try? $0.to.resolve(with: context)) ?? $0.to) }
            .map { $0.from }
            .forEach {
                Logger.log("Deleting \($0)",
                           level: .verbose)
                try? projectFolder.file(at: $0).delete()
                try? projectFolder.subfolder(at: $0).delete()
            }
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
