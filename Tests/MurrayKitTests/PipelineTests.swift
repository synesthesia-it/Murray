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

class PipelineSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "Pipeline")
        
        context("a pipeline") {
            describe("for simple context") {
                beforeEach {
                    
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
                    
                }
                it("should properly create data in target folder") {
                    
                    expect {
                        
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName:"simpleGroup", with: ["name": "simple"]) }.notTo(throwError())
                        
                        expect {
                            let fileContents = try root.file(at: "Sources/Files/simple/simple.swift").readAsString()
                            expect(fileContents) == "simpleTest"
                            return fileContents
                        }
                        .notTo(throwError())
                        return pipeline
                    }.notTo(throwError())
                    
                }
                it ("should properly find specs") {
                    expect { try BonePipeline(folder: root).execute(specName: "simple", boneName:"simpleGroup", with: ["name": "simple"]) }.notTo(throwError())
                }
            }
            
        describe("for single group, multiple bone items") {
                let names = ["test1","test2","test3"]
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.multipleItemsSingleGroup(names:names, from: root)
                }
                it("should properly create data in target folder") {
                    
                    expect {
                        
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName:"singleGroup", with: ["name": "someTest"]) }.notTo(throwError())
                        
                        expect {
                            let fileContents = try root.file(at: "Sources/Files/Test1/SomeTest.swift").readAsString()
                            expect(fileContents) == "someTestTest - Stefano Mondino"
                            return fileContents
                        }
                        .notTo(throwError())
                        return pipeline
                    }.notTo(throwError())
                    
                }
        
            }
        }
    }
}
