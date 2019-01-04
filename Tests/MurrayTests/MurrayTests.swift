import Foundation
import XCTest
import Files
import MurrayKit

class CommandLineToolTests: XCTestCase {

//    func testSetupTemplate() throws {
//        // Setup a temp test folder that can be used as a sandbox
//        let fileSystem = FileSystem()
//        let tempFolder = fileSystem.temporaryFolder
//        let testFolder = try tempFolder.createSubfolderIfNeeded(
//            withName: "CommandLineToolTests"
//        )
//
//        // Empty the test folder to ensure a clean state
//        try testFolder.empty()
//
//        // Make the temp folder the current working folder
//        let fileManager = FileManager.default
//        fileManager.changeCurrentDirectoryPath(testFolder.path)
//
//        // Create an instance of the command line tool
//        let url = URL(string:"git@github.com:synesthesia-it/Bones.git")!
//
//        XCTAssertNoThrow(try Template.setup(git:url), "Error!")
//    }
    func testInstallTemplate() throws {
        // Setup a temp test folder that can be used as a sandbox
//        let fileSystem = FileSystem()
//        let tempFolder = fileSystem.temporaryFolder
//        let testFolder = try tempFolder.createSubfolderIfNeeded(
//            withName: "CommandLineToolTests"
//        )
//
//        // Empty the test folder to ensure a clean state
//        try testFolder.empty()
//
//        // Make the temp folder the current working folder
//        let fileManager = FileManager.default
//        fileManager.changeCurrentDirectoryPath(testFolder.path)
//
//        let bonefile = "bone \"https://github.com/synesthesia-it/Bones.git\"".data(using: .utf8)
//        try testFolder.createFile(named: "Bonefile", contents: bonefile!)
//
//        // Create an instance of the command line tool
////        let url = URL(string:"git@github.com:synesthesia-it/Bones.git")!
//        XCTAssertNoThrow(try Bone.setup(), "Error!")
//        fileManager.changeCurrentDirectoryPath(testFolder.path)
//        try Bone.list()
    }
    func testCreateBone() throws {
        // Setup a temp test folder that can be used as a sandbox
//        let fileSystem = FileSystem()
//        let tempFolder = fileSystem.temporaryFolder
//        let testFolder = try tempFolder.createSubfolderIfNeeded(
//            withName: "CommandLineToolTests"
//        )
//
//        // Empty the test folder to ensure a clean state
//        try testFolder.empty()
//
//        // Make the temp folder the current working folder
//        let fileManager = FileManager.default
//        fileManager.changeCurrentDirectoryPath(testFolder.path)
//
//        try Bone.newBone(listName: "Custom", name: "Test", files: ["testA.swift", "testB.xib"])
//        try Bone.newBone(listName: "Custom", name: "Test2", files: ["testC.swift", "testD.xib"])
        // Create an instance of the command line tool
//        //        let url = URL(string:"git@github.com:synesthesia-it/Bones.git")!
//        XCTAssertNoThrow(try Template.setup(), "Error!")
//        fileManager.changeCurrentDirectoryPath(testFolder.path)
//        try Template.list()
    }
}
