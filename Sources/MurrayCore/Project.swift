
import Foundation
import Files
import ShellOut
import Commander

public final class Project {
    
    var git : URL
    var projectName : String
    var projectPath : String
    
    static func commands(for group:Group) {
        group.group("project") {
            $0.command(
                "new",
                Argument<String>("projectName", description: "Name of project"),
                Option<String>("git", default:"https://github.com/synesthesia-it/Skeleton.git", description:"Project's template git url")) {
                    projectName, git in
                    guard let url = URL(string: git) else {
                        return
                    }
                    try Project(projectName: projectName, git: url).run()
                    
            }
        }
        
    }
    
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
            if let proj = murrayFolder.subfolders.filter ({ ($0.extension ?? "") == "xcodeproj" }).first {
                //                let proj = try murrayFolder.subfolder(named: "App.xcodeproj")
                try proj.rename(to: "\(projectName).xcodeproj")
            }
            
            print ("Moving contents to proper folder")
            try murrayFolder.moveContents(to: folder, includeHidden: true)
            
            print ("Deleting skeleton folder")
            try murrayFolder.delete()
            if (try? folder.file(named: "Gemfile")) != nil {
                print ("Installing bundle")
                print (try shellOut(to: "bundle",
                                    arguments:["install","--path","vendor/bundle"]))
            }
            if (try? folder.file(named: "Podfile")) != nil {
                //TODO bundle exec only if gemfile
                print ("Installing pods")
                //
                print(try shellOut(to: "bundle",
                                   arguments:["exec","pod","install","--repo-update"]))
            }
            print("Git initialization")
            
            if (try? folder.file(named: "Bonefile")) != nil {
                print ("Installing Murray templates")
                print (try shellOut(to: "murray", arguments: ["template", "install"]))
            }
            print(try shellOut(to: .gitInit()))
            
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
    enum Error: String, Swift.Error, CustomStringConvertible{
        case missingProjectName
        case existingFolder
        case gitError
        case shellError
        
        public var description: String {
            return self.rawValue
        }
        public var localizedDescription: String {
            return self.rawValue
        }
    }
}
