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

class SkeletonPipelineSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "SkeletonPipeline/Project")
        let skeleton = tempFolder(for: "SkeletonPipeline/Skeleton")
        context("a skeleton pipeline") {
            describe("for simple context") {
                beforeEach {
                    try! root.empty()
                    try! skeleton.empty()
                    try! Mocks.Scenario.skeleton(from: skeleton)
                }
                it("should properly create data in target folder") {
                    expect {
                        let pipeline = try SkeletonPipeline(folder: root, projectName: "Murray")

                        expect { try pipeline.execute(projectPath: skeleton.path, with: [:]) }.notTo(throwError())
                        expect { try root.subfolder(at: "Murray/Murray.xcodeproj") }.notTo(throwError())
                        expect { try root.file(at: "Murray/Murray/Murray.swift") }.notTo(throwError())
                        expect { try root.file(at: "Murray/TouchMurray.txt") }.notTo(throwError())
                    }
                }
            }
        }
    }
}
