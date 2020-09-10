//
//  PipelineTests.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Files
import Foundation
import Nimble
import Quick

@testable import MurrayKit

class BoneCloneSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BoneClone")

        context("a pipeline") {
            describe("for simple context") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
                }
                it("should properly clone a remote bone") {
                    let command = BoneCloneCommand(url: "https://github.com/bellots/Vapor-Bones.git", targetFolder: "test")
                    command.folder = root
                    expect {
                        try command.execute()
                    }.notTo(throwError())
                }
            }
        }
    }
}
