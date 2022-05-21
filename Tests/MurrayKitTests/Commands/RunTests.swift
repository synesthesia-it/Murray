//
//  File.swift
//  
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation
import XCTest
@testable import MurrayKit

class RunTests: TestCase {
    
    func testSimpleRun() throws {
        let scenario = Scenario.simpleJSON
        let root = try scenario.make()
        let command = Run(folder: root,
                      mainPlaceholder: "name",
                      name: "simpleGroup",
                      preview: false,
                      verbose: false,
                          params: ["name:test"])
        try command.execute()
        let file = try root.file(at: "Sources/Files/test/test.swift")
        XCTAssertEqual(try file.readAsString(), "test Test\n")
    }
    
    func testSimpleRunWithPreview() throws {
        let scenario = Scenario.simpleJSON
        let root = try scenario.make()
        let command = Run(folder: root,
                          mainPlaceholder: "name",
                          name: "simpleGroup",
                          preview: true,
                          verbose: false,
                          params: ["name:test"])
        try command.execute()
        
        XCTAssertThrowsError(try root.file(at: "Sources/Files/test/test.swift"))
        
        XCTAssertFalse(logger.messages.isEmpty )
    }
    
}
