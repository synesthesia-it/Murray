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

class MurrayfileTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testJSONMurrayfileCreation() throws {
        try assertMurrayfile(scenario: .simpleJSON)
    }

    func testYAMLMurrayfileCreation() throws {
        try assertMurrayfile(scenario: .simpleYaml)
    }

    fileprivate func assertMurrayfile(scenario: Scenario, line: UInt = #line) throws {
        let root = try scenario.make()
        let murrayfile = try CodableFile<Murrayfile>(in: root).object
        XCTAssertEqual(murrayfile, scenario.murrayFile, line: line)
        let packagePath = try XCTUnwrap(murrayfile.packages.first)
        let package = try CodableFile<Package>(file: root.file(named: packagePath))
        XCTAssertEqual(package.object.procedures.count, 1)
    }
}
