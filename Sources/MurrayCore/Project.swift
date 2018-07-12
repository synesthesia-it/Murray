
import Foundation
import Files
import ShellOut


public final class Project {
    
    var git : URL
    var projectName : String
    var projectPath : String
    public init( projectName: String, git: URL, projectPath:String? = nil) {
        self.projectName = projectName
        self.git = git
        self.projectPath = "\(projectPath ?? ".")/\(projectName)"
    }
    
    public func run() throws {

        // The first argument is the execution path
        
        do {
            let fs = FileSystem()
            
            guard let folder = try? fs.createFolder(at: projectPath) else {
                throw Error.existingFolder
                
            }
            FileManager.default.changeCurrentDirectoryPath(folder.path)
            
            print ("Cloning skeleton app from \(git.absoluteString)")
            try shellOut(to:.gitClone(url:git))
            
            print ("Reorganizing folders")
            let murrayFolder = try folder.subfolder(named: "Skeleton")
            
            print ("Removing useless folders from cloned template")
            try murrayFolder.subfolder(named: ".git").delete()
            
            print ("Renaming project")
            let proj = try murrayFolder.subfolder(named: "App.xcodeproj")
            try proj.rename(to: "\(projectName).xcodeproj")
    
            print ("Moving contents to proper folder")
            try murrayFolder.moveContents(to: folder, includeHidden: true)
            
            print ("Deleting skeleton folder")
            try murrayFolder.delete()
            
            print ("Installing bundle")
            try shellOut(to: "bundle",
                         arguments:["install","--path","vendor/bundle"])
            
            print ("Installing pods")
            
            try shellOut(to: "bundle",
                         arguments:["exec","pod","install","--repo-update"])
            
            print("Git initialization")
            try shellOut(to: .gitInit())
            
            print ("Opening project")
            try shellOut(to: "open",
                         arguments:["*space"])
            
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
