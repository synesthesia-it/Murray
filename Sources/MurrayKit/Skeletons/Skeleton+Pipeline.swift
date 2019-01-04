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

        // The first argument is the execution path

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

            print ("Cloning skeleton app from \(git.absoluteString)")
            try DependencyManager.shared.cloneProject(from: git)

            print ("Reorganizing folders")
            //let murrayFolder = try folder.subfolder(named: "Skeleton")
            guard let skeletonFolder = folder.subfolders.filter ({ $0.nameExcludingExtension.count > 0}).first else {
                throw Error.gitEmpty
            }

            print ("Removing useless folders from cloned template")
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

//            if let proj = skeletonFolder.subfolders.filter ({ ($0.extension ?? "") == "xcodeproj" }).first {
//                //                let proj = try murrayFolder.subfolder(named: "App.xcodeproj")
//                try proj.rename(to: "\(projectName).xcodeproj")
//            }

            print ("Moving contents to proper folder")
            try skeletonFolder.moveContents(to: folder, includeHidden: true)

            print ("Deleting skeleton folder")
            try skeletonFolder.delete()
            /*if (try? folder.file(named: "Gemfile")) != nil {
                print ("Installing bundle")
                print (try shellOut(to: "bundle",
                                    arguments:["install","--path","vendor/bundle"]))
            }*/
            /*if (try? folder.file(named: "Podfile")) != nil {
                //TODO bundle exec only if gemfile
                print ("Installing pods")
                //
                print(try shellOut(to: "bundle",
                                   arguments:["exec","pod","install","--repo-update"]))
            }
            */

            if (try? folder.file(named: "Bonefile")) != nil {
                print ("Installing Murray templates")
                try Template.setup()
                //print (try shellOut(to: "murray", arguments: ["template", "install"]))
            }
            print("Git initialization")
            print(try shellOut(to: .gitInit()))

            let scripts = spec.scripts?.filter { $0.count > 0 }
            if let scripts = scripts, scripts.count > 0 {
                try shellOut(to: scripts)
            }

            //try shellOut(to: ["sh install.sh"])
            print ("Done!")

        } catch let error {
            if error is Error {
                throw error
            } else {
                throw error
            }
        }

    }
}
