//
//  ItemTests.swift
//
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
@testable import MurrayKit
import XCTest
import Yams

class ItemTests: TestCase {
    func testSimpleItem() throws {
        let file = try Folder.mock().file(at: "SimpleJSON/Murray/Simple/SimpleItem/SimpleItem.json")

        let item = try CodableFile<Item>(file: file).object
        XCTAssertEqual(item.name, "simpleItem")
        XCTAssertEqual(item.description, "custom description")
        XCTAssertEqual(item.paths.count, 1)

        let path = try XCTUnwrap(item.paths.first)
        XCTAssertEqual(path.from, "Bone.swift")
        XCTAssertEqual(path.to, "Sources/Files/{{ nestedName }}/{{ customName }}.swift")

        let requiredParameter = try XCTUnwrap(item.parameters.first)
        XCTAssertEqual(requiredParameter.name, "name")
        XCTAssertTrue(requiredParameter.isRequired)

        let optionalParameter = try XCTUnwrap(item.parameters.dropLast().last)
        XCTAssertEqual(optionalParameter.name, "type")
        XCTAssertFalse(optionalParameter.isRequired)

        let textReplacement = try XCTUnwrap(item.replacements.first)
        XCTAssertEqual(textReplacement.destination, "Sources/Files/Default/Test.swift")
        XCTAssertEqual(textReplacement.placeholder, "//Murray Placeholder")
        XCTAssertEqual(textReplacement.text, "{{ name }}")
        XCTAssertNil(textReplacement.source)

        let sourceReplacement = try XCTUnwrap(item.replacements.last)
        XCTAssertEqual(sourceReplacement.destination, "Sources/Files/Default/Test2.swift")
        XCTAssertEqual(sourceReplacement.placeholder, "//Murray Placeholder")
        XCTAssertEqual(sourceReplacement.text, "{{ name }}")
        XCTAssertEqual(sourceReplacement.source, "Replacement.swift")
    }

    func testInvalidReplacement() {
        let replacementYaml = """
        destination: somewhere
        placeholder: somePlaceholder
        """
        XCTAssertThrowsError(try YAMLDecoder(encoding: .utf8).decode(replacementYaml, of: Item.Replacement.self)) { error in
            XCTAssertEqual(error as? Errors, Errors.invalidReplacement)
        }

        let replacementJSON = """
        { "destination": "somewhere", "placeholder": "somePlaceholder"}
        """

        XCTAssertThrowsError(try JSONDecoder().decode(replacementJSON, of: Item.Replacement.self)) { error in
            XCTAssertEqual(error as? Errors, Errors.invalidReplacement)
        }
    }

    func testMissingReplacementAllowsMapping() throws {
        let yaml = """
        name: simpleItem
        description: custom description
        paths:
        - from: "Bone.swift"
          to: "Sources/Files/{{ nestedName }}/{{ customName }}.swift"
          plugins:
            xcode:
              targets: ["App"]
            shell:
              after:
              - "echo {{_destinationFilename}} >> /{{ _destinationPath }}.test"
        parameters:
        - "name": "name"
          "isRequired": true
        """
        let item = try YAMLDecoder(encoding: .utf8).decode(yaml, of: Item.self)
        XCTAssertEqual(item.replacements, [])
    }
}
