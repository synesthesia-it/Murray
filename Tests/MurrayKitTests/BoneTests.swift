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
        var defaultFolder = ""
        let projectName = "MurrayBonesTest"
        let fs = FileSystem()
        let boneFileSample = """
bone "https://github.com/synesthesia-it/Bones.git@develop"
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

            describe("setup from Bonefile") {
                beforeEach {
                    DependencyManager.reset()
                    try! reset()

                }
                it("should clone a Bones repository") {

//                    let project = Skeleton(projectName: projectName, git: url)
                    let defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
                    print (fs.currentFolder.path)
                    expect { try Bone.setup() }.notTo(throwError())
//                    expect { try project.run() }.notTo(throwError())
                    expect { try fs.currentFolder.subfolder(named: ".murray")}.notTo(throwError())

                    let tests = try? fs.currentFolder.createSubfolder(named: "Tests")
                    try? tests?.createSubfolder(named: "ModelLayerTests")

                    let sources = try? fs.currentFolder.createSubfolder(named: "Sources")
                    let modelLayer = try? sources?.createSubfolder(named: "ModelLayer")
                    try? modelLayer??.createSubfolder(named: "Models")

                    expect { try Bone(boneName: "modelWithTests", mainPlaceholder: "Test", context: [:]).run()
                    }.notTo(throwError())

                    FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                    expect(FileManager.default.currentDirectoryPath) == defaultFolder

                }
            }
        }
        context("in mocked environment") {
            beforeEach {
                DependencyManager.shared = TestDependency()
                try! reset()
            }
            describe("setup from Bonefile") {
                beforeEach {
                    try! reset()
                }
                it("should create files in specific directories") {
                    let defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
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
            describe("Listing bones") {

                describe("When single boneSpec is provided") {

                beforeEach {
                    try! reset()
                    defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
                    try! Bone.setup()
                }
                it("should should include everything") {
                    expect { try! Bone.list() }.to(equal(["Bones.test - A test\n\nBones.testLowercased - A test"]))
                }
                    afterEach {
                        FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                    }
                }
                describe("When multiple boneSpec is provided") {

                    beforeEach {
                        try! reset()
                        defaultFolder = FileManager.default.currentDirectoryPath
                        FileManager.default.changeCurrentDirectoryPath(projectName)
                        DependencyManager.shared = MultipleBonesTestDependency()
                        try! Bone.setup()
                    }
                it ("should namespace each bone in list if more than one bonespec is provided") {
                    expect { try! Bone.list() }.to(equal(["Bones.test - A test\n\nBones.testLowercased - A test", "TestB.test - A test\n\nTestB.testLowercased - A test"]))
                }
                    afterEach {
                        FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                    }
                }

            }
        }
            describe("creating a new bone") {
                var sources: Folder!
                beforeEach {
                    try! reset()
                    defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
                    try! Bone.setup()
                    sources = try! fs.createFolder(at: "Sources")
                }
                it("should create files in specific directories") {
                    let bone = try? Bone(boneName: "Bones.test", mainPlaceholder: "Test", context: [:])
                    expect(bone).notTo(beNil())
                    expect { try bone!.run() }.notTo(throwError())
                    let file = try? sources.file(named: "Test.swift")
                    expect(file).notTo(beNil())
                    expect { try file?.readAsString()} == TestDependency().templateResolved(with: "Test")
                }
                it("should create files in specific directories and follow specific placeholderReplace rule") {
                    let bone = try? Bone(boneName: "Bones.testLowercased", mainPlaceholder: "TEST", context: [:])
                    expect(bone).notTo(beNil())
                    expect { try bone!.run() }.notTo(throwError())
                    let file = try? sources.file(named: "tEST.swift")
                    expect(file).notTo(beNil())
                    expect(file?.name) == "tEST.swift"
                    expect { try file?.readAsString()} == TestDependency().templateResolved(with: "TEST")
                }
                it("should use the name value in context if no main placeholder is provided") {
                    let bone = try? Bone(boneName: "Bones.test", mainPlaceholder: nil, context: ["name": "Test"])
                    expect(bone).notTo(beNil())
                    expect { try bone!.run() }.notTo(throwError())
                    let file = try? sources.file(named: "Test.swift")
                    expect(file).notTo(beNil())
                    expect { try file?.readAsString()} == TestDependency().templateResolved(with: "Test")
                }
                it("should use the main placeholder over the name value in context if both are provided") {
                    let bone = try? Bone(boneName: "Bones.test", mainPlaceholder: "Test", context: ["name": "Not to be used value"])
                    expect(bone).notTo(beNil())
                    expect { try bone!.run() }.notTo(throwError())
                    let file = try? sources.file(named: "Test.swift")
                    expect(file).notTo(beNil())
                    expect { try file?.readAsString()} == TestDependency().templateResolved(with: "Test")
                }
                it ("should error out if multiple boneSpecs are provided and boneName is not in keyPath format") {
                    let bone = try? Bone(boneName: "test", mainPlaceholder: "Test", context: [:])
                    expect(bone).notTo(beNil())
                    expect { try bone!.run() }.to(throwError(Bone.Error.multipleBones))
                }
                afterEach {
                    FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                }
            }
    }
}
