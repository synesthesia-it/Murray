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
            describe("for default context") {
                
                beforeEach {
        
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
             
                }
                it("should properly create data in target folder") {
                    
                    expect {
                        
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute("simpleGroup", with: ["name": "simple"]) }.notTo(throwError())
                        expect {
                            let fileContents = try root.file(atPath: "Sources/Files/simple/simple.swift").readAsString()
                            expect(fileContents) == "simpleTest"
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
