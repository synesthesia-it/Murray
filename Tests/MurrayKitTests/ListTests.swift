//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation
@testable import MurrayKit
import XCTest

class ListTests: TestCase {
    
    func testSimpleList() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()
        let murrayfile = try CodableFile(in: root)
        let command = try List(murrayfile: murrayfile)
        let procedures = try command.list()
        XCTAssertEqual(procedures.count, 2)
    }
    
    func testListInFolder() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()
        
        let command = try List(folder: root, murrayfileName: "Murrayfile")
        let procedures = try command.list()
        XCTAssertEqual(procedures.count, 2)
    }
    
    func testCommandExecution() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()
       
        let command = try List(folder: root)
        try command.execute()
        XCTAssertFalse(logger.messages.isEmpty)
    }
    
    func testCommandFailedExecutionInWrongFolder() throws {
        let root = Folder.temporary
        XCTAssertThrowsError(try List(folder: root)) { error in
            XCTAssert(error is LocationError)
//            XCTAssertFalse(logger.messages.isEmpty)
        }
    }
}
