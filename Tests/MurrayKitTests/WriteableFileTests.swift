//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Files
import Foundation
import Yams
@testable import MurrayKit
import XCTest

class WriteableFileTests: TestCase {
    
    func testFileCreation() throws {
        let root = try Scenario.simpleJSON.make()
        let context = Template.Context(["name": "TEST"])
        let file = WriteableFile(content: .text("replaced with {{name}}"),
                                 path: "Sources/{{name}}/{{name}}.swift",
                                 destinationRoot: root,
                                 action: .create)
        
        
        XCTAssertEqual(try file.preview(context: context), "replaced with TEST")
        
        let destination = try file.commit(context: context)
        
        XCTAssertEqual(destination.path(relativeTo: root), "Sources/TEST/TEST.swift")
        XCTAssertEqual(try destination.readAsString(), "replaced with TEST")
        
    }
    
    func testFileReplacement() throws {
        let root = try Scenario.simpleJSON.make()
        let context = Template.Context(["name": "TEST", "customizedPath": "Default"])
        let placeholder = "//Murray Placeholder"
        
        let file = WriteableFile(content: .text("replaced with {{name}}\n"),
                                 path: "Sources/Files/{{customizedPath}}/Test.swift",
                                 destinationRoot: root,
                                 action: .edit(placeholder: placeholder))
        
        let expected = """
                        This is a test
                        replaced with TEST
                        //Murray Placeholder
                        
                        Enjoy
                        
                        """
        XCTAssertEqual(try file.preview(context: context), expected)
        
        let destination = try file.commit(context: context)
        
        XCTAssertEqual(destination.path(relativeTo: root), "Sources/Files/Default/Test.swift")
        XCTAssertEqual(try destination.readAsString(), expected)
    }
    
}
