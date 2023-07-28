//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
@testable import MurrayKit
import XCTest

class ListTests: TestCase {
    func testSimpleList() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()
        let murrayfile = try CodableFile<Murrayfile>(in: root)
        let command = List(murrayfile: murrayfile)
        let procedures = try command.list()
        XCTAssertEqual(procedures.count, 4)
    }

    func testListInFolder() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()

        let command = try List(folder: root, murrayfileName: "Murrayfile")
        let procedures = try command.list()
        XCTAssertEqual(procedures.count, 4)
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
            XCTAssertEqual(error as? Errors, Errors.murrayfileNotFound(root.path))
//            XCTAssert(error is LocationError)
//            XCTAssertFalse(logger.messages.isEmpty)
        }
    }
}
