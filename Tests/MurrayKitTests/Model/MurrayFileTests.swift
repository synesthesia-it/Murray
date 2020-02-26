//
//  BoneFileTests.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Quick
import Nimble
import Files

@testable import MurrayKit

class MurrayFileReaderSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BoneFile")
      
        context("a BoneFile object") {
            describe("created with default parameters") {
                
                beforeEach {
        
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
             
                }
                it("should properly map data") {
                  
                    expect {
                        let murrayfile = try root.file(named: "Murrayfile.json").decodable(MurrayFile.self)
                        expect(murrayfile).notTo(beNil())
                        expect(murrayfile?.packages) == ["Murray/Simple/Simple.json"]
                        let author = murrayfile?.environment["author"] as? String
                        expect(author) == "Stefano Mondino"
                        return murrayfile
                    }.notTo(throwError())
                    
                }
            }
        }
    }
}



