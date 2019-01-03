//
//  ProjectTests.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 03/01/2019.
//

import Foundation
import Quick
import Nimble
import Files
@testable import MurrayKit

class ProjectSpec: QuickSpec {
    override func spec() {
        
        let projectName = "MurrayProjectTest"
        let url = URL(string: "https://google.com")!
        let fs = FileSystem()
        
        beforeEach {
            DependencyManager.shared = TestDependency()
            
//            let fileSystem = FileSystem()
//            let tempFolder = fileSystem.temporaryFolder
//            let testFolder = try! tempFolder.createSubfolderIfNeeded(
//                withName: projectName
//            )
//            print (testFolder.path)
        }
        
        describe("creating a new Project") {
            beforeEach {
                
            }
            it("should clone a repository") {
                let project = Project(projectName: projectName, git: url)
                let defaultFolder = FileManager.default.currentDirectoryPath
                expect { try project.run() }.notTo(throwError())
                expect(FileManager.default.currentDirectoryPath) == defaultFolder
            }
            it ("should create a folder named \(projectName)") {
                print (fs.currentFolder.path)
                expect { try fs.currentFolder.subfolder(named: projectName) }.notTo(throwError())
            }
            
           
        }
    }
}
