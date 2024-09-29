//
//  PipelineTests.swift
//
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
@testable import MurrayKit
import XCTest
import Yams

class PipelineTests: TestCase {
    func testSimpleJSONPipeline() throws {
        let root = try Scenario.simpleJSON.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "simpleGroup",
                                    context: ["name": "test"])

        try pipeline.run()

        let file = try root.file(at: "Sources/Files/test/test.swift")
        XCTAssertEqual(try file.readAsString(), "test Test \(year)\n")
//        XCTAssertNoThrow(try root.file(at: "Sources/Files/test/.gitKeep"))
    }

    func testSimpleJSONPipelineWithMissingParameter() throws {
        let root = try Scenario.simpleJSON.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "simpleGroup",
                                    context: [:])
        let missingParameter = Item.Parameter(name: "name")
        XCTAssertThrowsError(try pipeline.run()) {
            XCTAssertEqual($0 as? Errors, Errors.missingRequiredParameters([missingParameter]))
        }

        XCTAssertThrowsError(try root.file(at: "Sources/Files/test/test.swift")) {
            XCTAssertEqual($0 as? Errors, Errors.fileLocationError(root.path.appendingPathComponent("Sources/Files/test/test.swift")))
        }
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
                                          procedures: ["simpleGroup", "wrongName"],
                                          context: ["name": "test"])) { error in
            XCTAssertEqual(error as? Errors, .procedureNotFound(name: "wrongName"))
        }
    }

    func testPluginExecutionWithCustomPlaceholders() throws {
        let root = try Scenario.simpleYaml.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "Simple.simpleGroup",
                                    context: ["name": "test"])

        try pipeline.run()

        let file = try root.file(at: "Sources/Files/test/test.swift.test")
        XCTAssertEqual(try file.readAsString(), "test.swift\n")
    }

    func testExecutionFailsIfProvidedValueIsNotPartOfAllowedList() throws {
        let root = try Scenario.simpleYaml.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "Simple.simpleGroup",
                                    context: ["name": "test", "type": "valueC"])
        let invalidParameter = Item.Parameter(name: "type",
                                              description: "The type of the item",
                                              values: ["valueA", "valueB"])
        XCTAssertThrowsError(try pipeline.run()) { error in
            XCTAssertEqual(error as? Errors?, Errors.invalidParameters([invalidParameter]))
        }
        // no file should be created
        XCTAssertThrowsError(try root.file(at: "Sources/Files/test/test.swift.test"))
    }

    func testXcodePluginAlteringXcodeProject() throws {
        let root = try Scenario.simpleYaml.make()
        let pipeline = try Pipeline(murrayfile: .init(in: root),
                                    procedure: "Simple.simpleGroup",
                                    context: ["name": "xcodeCustomFile"])
        let xcodeProjPreviousContents = try root.file(at: "Test.xcodeproj/project.pbxproj").readAsString()
        try pipeline.run()
        let xcodeProjUpdatedContents = try root.file(at: "Test.xcodeproj/project.pbxproj").readAsString()
        XCTAssertNotEqual(xcodeProjPreviousContents, xcodeProjUpdatedContents)
        // check that xcodeplugin is properly adding newly created file to proper target. This test can be improved a lot.
        XCTAssertTrue(xcodeProjUpdatedContents.contains("xcodeCustomFile.swift"))
        XCTAssertFalse(xcodeProjPreviousContents.contains("xcodeCustomFile.swift"))
    }
}
