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

class BoneJSONSpec: QuickSpec {

    override func spec() {
        var defaultFolder = ""
        let projectName = "MurrayBonesTest"
        let fs = FileSystem()
        let boneFileSample = """
bone "https://github.com/synesthesia-it/Bones.git@develop"
"""

        var folder: Folder!

        let reset = {
             try? fs.currentFolder.subfolder(atPath: projectName).delete()
             folder = try fs.currentFolder.createSubfolder(named: projectName)
             _ = try folder.createFile(named: "Bonefile", contents: boneFileSample)
        }

        beforeEach {
            Logger.logLevel = .verbose
        }

        context("when creating JSON classes from remote json") {
            beforeEach {
                DependencyManager.shared = JSONBonesTestDependency()
                try! reset()
            }
            
            describe("creating a new bone") {
                var sources: Folder!
                beforeEach {
                    try! reset()
                    defaultFolder = FileManager.default.currentDirectoryPath
                    FileManager.default.changeCurrentDirectoryPath(projectName)
                    try! Bone.setup()
                    sources = try! fs.createFolder(at: "Sources")
                }
                it("should create files in specific directories") {
                    let jsonInput = """
                                    {"id":139,"url":"http://www.tvmaze.com/shows/139/girls","name":"Girls","type":"Scripted","language":"English","genres":["Drama","Romance"],"status":"Ended","runtime":30,"premiered":"2012-04-15","officialSite":"http://www.hbo.com/girls","schedule":{"time":"22:00","days":["Sunday"]},"rating":{"average":6.7},"weight":94,"network":{"id":8,"name":"HBO","country":{"name":"United States","code":"US","timezone":"America/New_York"}},"webChannel":null,"externals":{"tvrage":30124,"thetvdb":220411,"imdb":"tt1723816"},"image":{"medium":"http://static.tvmaze.com/uploads/images/medium_portrait/31/78286.jpg","original":"http://static.tvmaze.com/uploads/images/original_untouched/31/78286.jpg"},"summary":"<p>This Emmy winning series is a comic look at the assorted humiliations and rare triumphs of a group of girls in their 20s.</p>","updated":1543140952,"_links":{"self":{"href":"http://api.tvmaze.com/shows/139"},"previousepisode":{"href":"http://api.tvmaze.com/episodes/1079686"}}}
                        """
                    
                    let jsonDictionary = try! JSONSerialization.jsonObject(with: jsonInput.data(using: .utf8)!, options: [])
                    let bone = try? Bone(boneName: "Bones.test", mainPlaceholder: "Test", context: ["json":jsonDictionary])
                    expect(bone).notTo(beNil())
                    expect { try bone!.run() }.notTo(throwError())
                    let file = try? sources.file(named: "Test.swift")
                    expect(file).notTo(beNil())
                    print (try! file!.readAsString())
                    //expect { try file?.readAsString()} == TestDependency().templateResolved(with: "Test")
                }
                
                afterEach {
                    FileManager.default.changeCurrentDirectoryPath(defaultFolder)
                }
            }
        }
    }
}
