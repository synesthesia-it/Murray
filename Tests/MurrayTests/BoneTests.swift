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

class BoneSpec: QuickSpec {
    
    override func spec() {

        let projectName = "MurrayBonesTest"
        let fs = FileSystem()
        let boneFileSample = """
bone "https://github.com/synesthesia-it/Bones.git"
"""
        
        var folder: Folder!
        
        let reset = {
             try? fs.currentFolder.subfolder(atPath: projectName).delete()
             folder = try fs.currentFolder.createSubfolder(named: projectName)
             _ = try folder.createFile(named: "Bonefile", contents: boneFileSample)
        }
        
        beforeEach {
            Logger.logLevel = .verbose
        }
        
        context("in real environment") {
            beforeEach {
                DependencyManager.reset()
                try! reset()
                
            }
            describe("setup from Bonefile") {
                it("should clone a Bones repository") {
                    
//                    let project = Skeleton(projectName: projectName, git: url)
                    let defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
                    print (fs.currentFolder.path)
                    expect { try Bone.setup() }.notTo(throwError())
//                    expect { try project.run() }.notTo(throwError())
                    expect { try fs.currentFolder.subfolder(named: ".murray")}.notTo(throwError())
                    FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                    expect(FileManager.default.currentDirectoryPath) == defaultFolder
                }
            }
        }
        context("in mocked environment") {
            beforeEach {
                DependencyManager.shared = TestDependency()
            }
            describe("setup from Bonefile") {
                beforeEach {
                    DependencyManager.shared = TestDependency()
                    try! reset()
                }
                it("should create files in specific directories") {
                    let defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
                    print (fs.currentFolder.path)
                    expect { try Bone.setup() }.notTo(throwError())
                    //                    expect { try project.run() }.notTo(throwError())
                    let murrayFolder = try? fs.currentFolder.subfolder(named: ".murray")
                    expect(murrayFolder).notTo(beNil())
                    
                    let bonesFolder = try? murrayFolder!.subfolder(named: "Bones")
                    expect(bonesFolder).notTo(beNil())
                    expect(bonesFolder!.containsFile(named: "Bonespec.json")) == true
                    let sourcesFolder = try? bonesFolder!.subfolder(named: "Files")
                    expect(sourcesFolder).notTo(beNil())
                    let source = try? sourcesFolder!.file(named: "Bone.swift")
                    expect(source).notTo(beNil())
                    let contents = try? source!.readAsString()
                    expect(contents).notTo(beNil())
                    expect(contents) == TestDependency().boneTemplate
                    FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                    expect(FileManager.default.currentDirectoryPath) == defaultFolder
                }

                
            }

        }
    }
}
