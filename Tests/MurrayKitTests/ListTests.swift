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

class ListTests: XCTestCase {
    func testSimpleList() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()
        let murrayfile = try CodableFile(in: root)
        let command = try List(murrayfile: murrayfile)
        let procedures = try command.list()
        XCTAssertEqual(procedures.count, 1)
    }
    func testListInFolder() throws {
        let scenario = Scenario.simpleYaml
        let root = try scenario.make()
        
        let command = try List(folder: root, murrayfileName: "Murrayfile")
        let procedures = try command.list()
        XCTAssertEqual(procedures.count, 1)
    }
}
