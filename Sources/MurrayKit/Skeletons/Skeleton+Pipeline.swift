import Foundation
import Files
import ShellOut

public final class Skeleton {

    var git: URL
    var projectName: String
    var projectPath: String
    var fileManager: FileManager

    public init(projectName: String, git: URL, projectPath: String? = nil) {
        self.projectName = projectName
        self.git = git
        self.projectPath = "\(projectPath ?? ".")/\(projectName)"
        self.fileManager = FileManager()
    }

    public func run() throws {

        do {
            let fs = FileSystem(using: fileManager)
            //File manager path should always restored to its original value after execution.
            //This helps testing and doesn't allow any subsequent operation to depend upon directory switching
            let defaultFolder = fileManager.currentDirectoryPath
            defer {
                fileManager.changeCurrentDirectoryPath(defaultFolder)
            }
            if fs.currentFolder.containsSubfolder(named: projectPath) {
                throw Error.existingFolder
            }
            guard let folder = try? fs.createFolder(at: projectPath) else {
                throw Error.existingFolder
            }

            fileManager.changeCurrentDirectoryPath(folder.path)

            Logger.log("Cloning skeleton app from \(git.absoluteString)", level: .verbose)
            try DependencyManager.shared.cloneSkeleton(from: git)

            Logger.log("Reorganizing folders", level: .verbose)
            //let murrayFolder = try folder.subfolder(named: "Skeleton")
            guard let skeletonFolder = folder.subfolders.filter ({ $0.nameExcludingExtension.count > 0}).first else {
                throw Error.gitEmpty
            }

            Logger.log ("Removing useless folders from cloned template", level: .verbose)
            try skeletonFolder.subfolder(named: ".git").delete()

            let spec = try SkeletonSpec.parse(from: skeletonFolder)
            Logger.log("Renaming Files", level: .verbose)
            try spec.filesToRename?
                .map { try skeletonFolder.file(atPath: $0) }
                .forEach { file throws in
                    let newName = file.name.replacingOccurrences(of: spec.filePlaceholder, with: projectName)
                    try file.rename(to: newName)
            }

            Logger.log ("Renaming folders", level: .verbose)

            try spec.foldersToRename?
                .map { try skeletonFolder.subfolder(atPath: $0) }
                .compactMap {$0}
                .forEach { folder in
                    let newName = folder.name
                        .replacingOccurrences(of: spec.filePlaceholder, with: projectName)
                    try folder.rename(to: newName)
            }
            Logger.log ("Moving contents to proper folder", level: .verbose)
            try skeletonFolder.moveContents(to: folder, includeHidden: true)

            Logger.log ("Deleting skeleton folder", level: .verbose)
            try skeletonFolder.delete()
            if (try? folder.file(named: "Bonefile")) != nil {
                Logger.log("Installing Murray templates", level: .verbose)
                try Bone.setup()
            }
            Logger.log("Git initialization", level: .verbose)
            Logger.log(try shellOut(to: .gitInit()), level: .verbose)

            Logger.log("Running custom scripts", level: .verbose)
            let scripts = spec.scripts?.filter { $0.count > 0 }
            if let scripts = scripts, scripts.count > 0 {
                try shellOut(to: scripts)
            }
            Logger.log("Done!", level: .verbose)

        } catch let error {
            if error is Error {
                throw error
            } else {
                throw error
            }
        }

    }
}
