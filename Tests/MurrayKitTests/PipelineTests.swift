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

class PipelineTests: XCTestCase {
    
    func testSimpleJSONPipeline() throws {
        let root = try Scenario.simpleJSON.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                procedure: "simpleGroup",
                                context: ["name": "test"])
        
        
    }
    
    func testSimpleJSONPipelineProcedureNotFound() throws {
        let root = try Scenario.simpleJSON.make()
        XCTAssertThrowsError(try Pipeline(murrayfile: .init(in: root),
                                procedure: "wrongName",
                                          context: ["name": "test"])) { error in
            XCTAssertEqual(error as? Errors, .procedureNotFound(name: "wrongName"))
        }
    }
}
