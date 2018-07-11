
import Foundation
import Files
import ShellOut


public final class Skeleton {
    private let arguments: [String]
    
    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }
    
    public func run() throws {
        guard arguments.count > 1 else {
            throw Error.missingProjectName
        }
        // The first argument is the execution path
        let projectName = arguments[1]
        
        do {
            let fs = FileSystem()
            let folder = try fs.createFolder(at: projectName)
            FileManager.default.changeCurrentDirectoryPath(folder.path)
        
            let url = URL(string:"git@github.com:synesthesia-it/Murray.git")!
            print ("Cloning Murray from \(url.absoluteString)")
            try shellOut(to:.gitClone(url:url))
            print ("Reorganizing folders")
            let murrayFolder = try folder.subfolder(named: "Murray")
            print ("Removing useless folders from cloned template")
            try murrayFolder.subfolder(named: ".git").delete()
            try murrayFolder.subfolder(named: "Murray").delete()
            print ("Moving contents to proper folder")
            try murrayFolder.moveContents(to: folder, includeHidden: true)
            print ("Environment setup")
            try shellOut(to: ShellOutCommand(string: "./install.sh"),
                         outputHandle:FileHandle.standardOutput,
                         errorHandle:FileHandle.standardError)
            print ("Done!")
            exit(0)
            
        } catch {
            throw Error.existingFolder
        }
    }
}
public extension Skeleton {
    enum Error: Swift.Error {
        case missingProjectName
        case existingFolder
        case gitError
    }
}
