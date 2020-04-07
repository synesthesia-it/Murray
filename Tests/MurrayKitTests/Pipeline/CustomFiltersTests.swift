//
//  PipelineTests.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Quick
import Nimble
import Files

@testable import MurrayKit

class CustomFiltersSpec: QuickSpec {
    private func resolveFilter(_ filter: String, with param: String) -> String {
        return (try? "{{name|\(filter)}}".resolved(with: BoneContext(["name": param], environment: [:]))) ?? ""
    }
    override func spec() {

        context("filters") {
            describe("firstUppercase") {

                it("should uppercase only the first letter") {
                    let filter = "firstUppercase"
                    expect(self.resolveFilter(filter, with: "test")) == "Test"
                    expect(self.resolveFilter(filter, with: "Test")) == "Test"
                    expect(self.resolveFilter(filter, with: "TesT")) != "Test"
                    expect(self.resolveFilter(filter, with: "TesT")) == "TesT"
                }
            }
            describe("snakeCase") {

                it("should uppercase only the first letter") {
                    let filter = "snakeCase"
                    expect(self.resolveFilter(filter, with: "testWithSomething")) == "test_with_something"
                    expect(self.resolveFilter(filter, with: "testABCWithSomething")) == "test_abc_with_something"
                    expect(self.resolveFilter(filter + "|uppercase", with: "testWithSomething")) == "test_with_something".uppercased()

                }
            }
        }
    }
}
