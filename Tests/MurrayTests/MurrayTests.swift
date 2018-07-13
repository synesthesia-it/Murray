import Foundation
import XCTest
import Files
import MurrayCore

class CommandLineToolTests: XCTestCase {
    
    func testSetupTemplate() throws {
        // Setup a temp test folder that can be used as a sandbox
        let fileSystem = FileSystem()
        let tempFolder = fileSystem.temporaryFolder
        let testFolder = try tempFolder.createSubfolderIfNeeded(
            withName: "CommandLineToolTests"
        )
        
        // Empty the test folder to ensure a clean state
        try testFolder.empty()
        
        // Make the temp folder the current working folder
        let fileManager = FileManager.default
        fileManager.changeCurrentDirectoryPath(testFolder.path)
        
        // Create an instance of the command line tool
        let url = URL(string:"git@github.com:synesthesia-it/Bones.git")!
        
        XCTAssertNoThrow(try Template.setup(git:url), "Error!")
    }
}
