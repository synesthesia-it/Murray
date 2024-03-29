//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
@testable import MurrayKit
import XCTest

class MurrayfileTests: TestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    func testJSONMurrayfileCreation() throws {
        try assertMurrayfile(scenario: .simpleJSON)
    }

    func testYAMLMurrayfileCreation() throws {
        try assertMurrayfile(scenario: .simpleYaml)
    }

    fileprivate func assertMurrayfile(scenario: Scenario,
                                      file _: StaticString = #file,
                                      line _: UInt = #line) throws {
        let root = try scenario.make()
        let murrayfile = try CodableFile<Murrayfile>(in: root).object
        let packagePath = try XCTUnwrap(murrayfile.packages.first)
        let package = try CodableFile<Package>(file: root.file(named: packagePath))
        XCTAssertGreaterThan(package.object.procedures.count, 0)
        XCTAssertEqual(murrayfile.pluginData?["shell"]?["after"]?.first, "echo test >> plugin.data")
        let name: String? = murrayfile.enrichedEnvironment["author"]
        XCTAssertEqual(name, "Stefano Mondino")
    }
}
