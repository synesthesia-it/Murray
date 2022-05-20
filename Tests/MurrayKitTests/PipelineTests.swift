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

class PipelineTests: TestCase {
    
    func testSimpleJSONPipeline() throws {
        let root = try Scenario.simpleJSON.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "simpleGroup",
                                    context: ["name": "test"])
        
        try pipeline.run()
        
        let file = try root.file(at: "Sources/Files/test/test.swift")
        XCTAssertEqual(try file.readAsString(), "test Test\n")
        
    }
    func testFolderReplacementPipeline() throws {
        let root = try Scenario.simpleJSON.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "folder",
                                    context: ["name": "test"])
        
        try pipeline.run()
        
        XCTAssertEqual(try root.file(at: "Sources/Files/test/test.swift").readAsString(),
                       "testing test in place\n")
        XCTAssertEqual(try root.file(at: "Sources/Files/test/AnotherSubfolderWithtest/test.swift").readAsString(),
                       "testing test in place\n")
    }
    
    func testSingleProcedureNotFound() throws {
        let root = try Scenario.simpleJSON.make()
        XCTAssertThrowsError(try Pipeline(murrayfile: .init(in: root),
                                          procedure: "wrongName",
                                          context: ["name": "test"])) { error in
            XCTAssertEqual(error as? Errors, .procedureNotFound(name: "wrongName"))
        }
    }
    
    func testSingleProcedureNotFoundInMultipleProcedureSetup() throws {
        let root = try Scenario.simpleJSON.make()
        XCTAssertThrowsError(try Pipeline(murrayfile: .init(in: root),
                                          procedures: ["simpleGroup","wrongName"],
                                          context: ["name": "test"])) { error in
            XCTAssertEqual(error as? Errors, .procedureNotFound(name: "wrongName"))
        }
    }
}
