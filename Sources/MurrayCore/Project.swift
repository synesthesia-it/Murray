
import Foundation
import Files
import ShellOut


public final class Project {
    
    var git : URL
    var projectName : String
    
    public init( projectName: String, git: URL) {
        self.projectName = projectName
        self.git = git
    }
    
    public func run() throws {

        // The first argument is the execution path
        
        do {
            let fs = FileSystem()
            
            guard let folder = try? fs.createFolder(at: projectName) else {
                throw Error.existingFolder
                
            }
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
            
            try shellOut(to: "bundle",
                         arguments:["install","--path","vendor/bundle"],
                         outputHandle:FileHandle.standardOutput,
                         errorHandle:FileHandle.standardError)
            
            try shellOut(to: "bundle",
                         arguments:["exec","pod","install",],
                         outputHandle:FileHandle.standardOutput,
                         errorHandle:FileHandle.standardError)
            
            try shellOut(to: "open",
                         arguments:["*space"],
                         outputHandle:FileHandle.standardOutput,
                         errorHandle:FileHandle.standardError)
            
            
            print ("Done!")
            exit(0)
            
        } catch let error {
            if error is Error {
                throw error
            } else {
                throw Error.shellError
            }
        }
    }
}

public extension Project {
    enum Error: Swift.Error {
        case missingProjectName
        case existingFolder
        case gitError
        case shellError
    }
}
