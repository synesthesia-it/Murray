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

class BonePipelineSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BonePipeline")

        context("a pipeline") {
            describe("for simple context") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
                }
                it("should properly create data in target folder") {
                    expect {
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName: "simpleGroup", with: ["name": "simple"]) }.notTo(throwError())

                        expect {
                            let fileContents = try root.file(at: "Sources/Files/simple/simple.swift").readAsString()
                            expect(fileContents) == "simpleTest"
                            return fileContents
                        }
                        .notTo(throwError())

                        expect {
                            let fileContents = try root.file(at: Mocks.BoneItem.placeholderFilePath).readAsString()
                            expect(fileContents) == "This is a test\nsimple\(Mocks.BoneItem.placeholder)\n\nEnjoy"
                            return fileContents
                        }.notTo(throwError())

                        expect {
                            let fileContents = try root.file(at: Mocks.BoneItem.placeholderFilePath2).readAsString()
                            expect(fileContents) == "This is a test\ntesting simple in place\n\(Mocks.BoneItem.placeholder)\n\nEnjoy"
                            return fileContents
                        }.notTo(throwError())

                        return pipeline
                    }.notTo(throwError())
                    expect { try root.file(at: "before_item").readAsString() }.notTo(throwError())
                    expect { try root.file(at: "after_item").readAsString() }.notTo(throwError())
                    expect { try root.file(at: "before_procedure").readAsString() }.notTo(throwError())
                    expect { try root.file(at: "after_procedure").readAsString() }.notTo(throwError())
                    expect { try root.file(at: "before_path").readAsString() }.notTo(throwError())
                    expect { try root.file(at: "after_path").readAsString() }.notTo(throwError())
                }
                it("should properly find specs") {
                    expect { try BonePipeline(folder: root).execute(packageName: "simple", boneName: "simpleGroup", with: ["name": "simple"]) }.notTo(throwError())
                }
            }

            describe("for single group, multiple bone items") {
                let names = ["test1", "test2", "test3"]
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.multipleItemsSingleGroup(names: names, from: root)
                }
                it("should properly create data in target folder") {
                    expect {
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName: "singleGroup", with: ["name": "someTest"]) }.notTo(throwError())

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
            describe("when subfolders") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.nestedFolders(from: root)
                }
                it("should replicate folder structure") {
                    expect {
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName: "nestedFolders", with: ["name": "someTest2"]) }.notTo(throwError())
                        expect { try root.subfolder(at: "Sources/Subfolder/Subfolder/Nested") }.to(throwError())
                        expect { try root.subfolder(at: "Sources/Subfolder/Nested/Nested2") }.notTo(throwError())
                        expect { try root.file(at: "Sources/Subfolder/externalFile.txt")
                        }.notTo(throwError())
                        expect { try root.file(at: "Sources/Files/Bone.swift")
                        }.notTo(throwError())
                        expect { try root.file(at: "Sources/Subfolder/Nested/Nested2/file.txt")
                        }.notTo(throwError())
                        expect { try root.file(at: "Sources/Subfolder/Nested/Nested2/file.txt").readAsString()
                        } == "someTest2"

                        return pipeline
                    }.notTo(throwError())
                }
            }
            describe("when parameters are required") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.parameterRequired(from: root)
                }
                it("should not allow creation of bones if required parameters are not provided") {
                    expect {
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName: "simpleGroup", with: ["name": "someTest2"]) }.to(throwError())
                        expect { try pipeline.execute(boneName: "simpleGroup", with: ["name": "someTest3", "type": "the type"]) }.notTo(throwError())

                        return pipeline
                    }.notTo(throwError())
                }
            }

            describe("when absolute paths are provided for packages in Murrayfile") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.absolute(from: root)
                }
                it("should properly create data in target folder") {
                    expect {
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName: "simpleGroup", with: ["name": "simple"]) }.notTo(throwError())

                        expect {
                            let fileContents = try root.file(at: "Sources/Files/simple/simple.swift").readAsString()
                            expect(fileContents) == "simpleTest"
                            return fileContents
                        }
                        .notTo(throwError())

                        expect {
                            let fileContents = try root.file(at: Mocks.BoneItem.placeholderFilePath).readAsString()
                            expect(fileContents) == "This is a test\nsimple\(Mocks.BoneItem.placeholder)\n\nEnjoy"
                            return fileContents
                        }.notTo(throwError())

                        expect {
                            let fileContents = try root.file(at: Mocks.BoneItem.placeholderFilePath2).readAsString()
                            expect(fileContents) == "This is a test\ntesting simple in place\n\(Mocks.BoneItem.placeholder)\n\nEnjoy"
                            return fileContents
                        }.notTo(throwError())

                        return pipeline
                    }.notTo(throwError())
                }
                it("should properly find specs") {
                    expect { try BonePipeline(folder: root).execute(packageName: "simple", boneName: "simpleGroup", with: ["name": "simple"]) }.notTo(throwError())
                }
            }
            describe("when invalid JSON is provided in BoneItem file") {
                beforeEach {
                    try! root.empty()
                    try! Mocks.Scenario.invalidJSONInItem(from: root)
                }
                it("should fail with appropriate description") {
                    expect {
                        let pipeline = try BonePipeline(folder: root)
                        expect { try pipeline.execute(boneName: "simpleGroup", with: ["name": "simple"]) }.to(throwError(closure: {
                            expect(($0 as? CustomError)?.code) == CustomError.Code.undecodable
                        }))

                        return pipeline
                    }.notTo(throwError())
                }
            }
        }
    }
}
