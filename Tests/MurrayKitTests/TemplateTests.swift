//
//  File.swift
//
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation
@testable import MurrayKit
import XCTest

class TemplateTests: TestCase {
    private func test(_ text: String,
                      context: Template.Context,
                      expected: String,
                      file: StaticString = #file,
                      line: UInt = #line) throws {
        let template = Template(text, context: context)
        XCTAssertEqual(try template.resolve(), expected, file: file, line: line)
    }

    func testSimpleStringConversion() throws {
        try test("{{name}} is in the house",
                 context: ["name": "John Doe"],
                 expected: "John Doe is in the house")
    }

    func testAdditionalSwiftContext() throws {
        let string = """
        {%- set aVariable %}{{true}}{% endset %}
        {%- if aVariable %}{{name}}{%endif%}
        """
        try test(string,
                 context: ["name": "John Doe"],
                 expected: "John Doe")
    }

    func testStringConversionWithCustomFilters() throws {
        try test("{{name|uppercase}} is in the house",
                 context: ["name": "John Doe"],
                 expected: "JOHN DOE is in the house")

        try test("{{name|lowercase}} is in the house",
                 context: ["name": "John Doe"],
                 expected: "john doe is in the house")

        try test("{{name|firstUppercase}}ViewController",
                 context: ["name": "test"],
                 expected: "TestViewController")

        try test("{{name|firstLowercase}}ViewController",
                 context: ["name": "Test"],
                 expected: "testViewController")

        try test("{{name|snakeCase}}ViewController",
                 context: ["name": "TestWithSnakeCaseStuff"],
                 expected: "test_with_snake_case_stuffViewController")
    }

    func testNestedParametersConversion() throws {
        try test("{{person.firstname}} {{person.lastname|uppercase}}",
                 context: ["person": ["firstname": "John", "lastname": "Doe"]],
                 expected: "John DOE")
    }

    func testContextWithGlobalEnvironment() throws {
        try test("{{person.firstname}} {{person.lastname|uppercase}} ©{{year}}",
                 context: .init(["person": ["firstname": "John", "lastname": "Doe"]],
                                environment: ["year": "2022"]),
                 expected: "John DOE ©2022")
    }

    func testSimpleFileConversion() throws {
        let file = try Folder.mock().file(at: "SimpleJSON/Murray/Simple/SimpleItem/Bone.swift")
        let template = try Template(file, context: ["name": "Some random test", "_year": "2023"])
        XCTAssertEqual(try template.resolve(), "Some random test Test 2023\n")
    }
}
