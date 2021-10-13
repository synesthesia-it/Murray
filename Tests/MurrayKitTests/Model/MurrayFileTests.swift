//
//  BoneFileTests.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Files
import Foundation
import Nimble
import Quick

@testable import MurrayKit

class MurrayFileReaderSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "Murrayfile")

        context("a JSON Murrayfile object") {
            describe("created with default parameters") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
                }
                it("should properly map data") {
                    let murrayfile = try root.file(named: "Murrayfile").decodable(MurrayFile.self)
                    expect(murrayfile).notTo(beNil())
                    expect(murrayfile?.packages) == ["Murray/Simple/Simple.json"]
                    let author = murrayfile?.environment["author"] as? String
                    expect(author) == "Stefano Mondino"
                }
            }
        }
        context("a YAML Murrayfile object") {
            describe("created with default parameters") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root, useYAML: true)
                }
                it("should properly map data") {
                    let murrayfile = try root.file(named: "Murrayfile").decodable(MurrayFile.self)
                    expect(murrayfile).notTo(beNil())
                    expect(murrayfile?.packages) == ["Murray/Simple/Simple.json"]
                    let author = murrayfile?.environment["author"] as? String
                    expect(author) == "Stefano Mondino"
                }
            }
        }
        context("a default Murrayfile object") {
            describe("created with default parameters and no murrayfile extension") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root, useYAML: true)
                }
                it("should properly map data") {
                    let murrayfile = try root.file(named: "Murrayfile").decodable(MurrayFile.self)
                    expect(murrayfile).notTo(beNil())
                    expect(murrayfile?.packages) == ["Murray/Simple/Simple.json"]
                    let author = murrayfile?.environment["author"] as? String
                    expect(author) == "Stefano Mondino"
                }
            }
        }
    }
}
