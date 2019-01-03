//
//  ProjectTests.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 03/01/2019.
//

import Foundation
import Quick
import Nimble
import Files
@testable import MurrayKit

class TemplateSpec: QuickSpec {
    override func spec() {
        
        beforeEach {
            DependencyManager.shared = TestDependency()
        }
        
        describe("creating a new file template") {
            
            it("should render template file as is when no context is provided") {
                let fileString = "This is a test named Empty"
                let template = FileTemplate(fileContents: fileString, context: [:])
                expect { try template.render() } == fileString
            }
            it("should change simple placeholders in file") {
                let fileString = "This is a test named {{ test }}"
                let template = FileTemplate(fileContents: fileString, context: ["test" : "Foo"])
                expect { try template.render() } == "This is a test named Foo"
            }
            it("should change simple placeholders in file and uppercase") {
                let fileString = "This is a test named {{ test|uppercase }}"
                let template = FileTemplate(fileContents: fileString, context: ["test" : "Foo"])
                expect { try template.render() } == "This is a test named FOO"
            }
            it("should change simple placeholders in file and uppercase first letter") {
                let fileString = "This is a test named {{ test|firstUppercase }}"
                let template = FileTemplate(fileContents: fileString, context: ["test" : "foo"])
                expect { try template.render() } == "This is a test named Foo"
            }
            it("should change simple placeholders in file and lowercase first letter") {
                let fileString = "This is a test named {{ test|firstLowercase }}"
                let template = FileTemplate(fileContents: fileString, context: ["test" : "FoO"])
                expect { try template.render() } == "This is a test named foO"
            }
            
            
            it("should change complex placeholders in file") {
                let fileString = "This is a test named {{ test.name }} and has a description {{ test.description}}"
                let template = FileTemplate(fileContents: fileString, context: ["test" : ["name": "Foo", "description": "Bar"]])
                expect  { try template.render() } == "This is a test named Foo and has a description Bar"
            }
        }
    }
}
