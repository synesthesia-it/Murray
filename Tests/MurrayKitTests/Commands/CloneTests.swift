//
//  File.swift
//
//
//  Created by Stefano Mondino on 26/07/22.
//

import Foundation
@testable import MurrayKit
import XCTest

class CloneTests: TestCase {
    private func makeGit(in folder: Folder) throws -> Folder {
        try ["git init",
             "git config user.email \"somebody@synesthesia.it\"",
             "git config user.name \"John Doe\"",
             "git add .",
             "git commit -m \"test\""]
            .forEach {
                print("Executing: `\($0)` in \(folder)")
                do {
                    try Process().launchBash(with: $0, in: folder)
                } catch {
                    print((error as? ShellOutError)?.message ?? "")
                    throw error
                }
            }

        return folder
    }

    private func makeOriginalGit() throws -> Folder {
        try makeGit(in: Scenario.cloneOrigin.make())
    }

    private func makeSubfolderGit() throws -> Folder {
        return try makeGit(in: Scenario.cloneOriginInSubfolder.make())
    }

    @discardableResult
    private func checks(folder: Folder,
                        projectName: String,
                        initGitAfterResolution: Bool,
                        file _: String = #file,
                        line _: UInt = #line) throws -> Folder {
        let projectFolder = try folder.subfolder(named: projectName)
        if !initGitAfterResolution {
            XCTAssertThrowsError(try projectFolder.subfolder(named: ".git"))
        } else {
            XCTAssertEqual(try projectFolder.subfolder(named: ".git").name, ".git")
        }

        XCTAssertThrowsError(try projectFolder.subfolder(named: "{{name}}"))

        let resolvedFolder = try projectFolder.subfolder(named: projectName)

        XCTAssertEqual(try resolvedFolder.file(named: "HelloLOCALGIT.swift").readAsString(), "Swift LocalGit\n")

        XCTAssertEqual(try projectFolder.file(named: "hello.txt").readAsString(), "Hello\n")

        XCTAssertThrowsError(try projectFolder.file(named: "Skeleton.yml"))
        return projectFolder
    }

    func testSimpleClone() throws {
        let git = try makeOriginalGit()
        let folder = try Scenario.folder()
        let projectName = "LocalGit"

        try? folder.subfolder(named: projectName).delete()

        let clone = Clone(path: git.path,
                          folder: folder,
                          mainPlaceholder: projectName,
                          copyFromLocalFolder: true)
        try clone.execute()

        let projectFolder = try checks(folder: folder,
                                       projectName: projectName,
                                       initGitAfterResolution: false)
        XCTAssertEqual(try projectFolder.file(at: "main.swift").readAsString(), "// LocalGit.swift\n")
    }

    func testCloneWithSubfolder() throws {
        let git = try makeSubfolderGit()
        let folder = try Scenario.folder()
        let projectName = "LocalGit"

        try? folder.subfolder(named: projectName).delete()

        let clone = Clone(path: git.path,
                          folder: folder,
                          subfolderPath: "Subfolder",
                          mainPlaceholder: projectName,
                          copyFromLocalFolder: true)
        try clone.execute()

        try checks(folder: folder,
                   projectName: projectName,
                   initGitAfterResolution: true)
    }

    func testCloneWithPath() throws {
        let git = try Scenario.cloneOrigin.make()
        try git.createFileIfNeeded(at: "uncommitted.txt",
                                   contents: "uncommitted".data(using: .utf8))
        let folder = try Scenario.folder()
        let projectName = "LocalGit"

        try? folder.subfolder(named: projectName).delete()

        let clone = Clone(path: git.path,
                          folder: folder,
                          mainPlaceholder: projectName,
                          copyFromLocalFolder: true)
        try clone.execute()

        try checks(folder: folder,
                   projectName: projectName,
                   initGitAfterResolution: false)

        let projectFolder = try folder.subfolder(named: projectName)
        XCTAssertEqual(try projectFolder.file(at: "uncommitted.txt").readAsString(), "uncommitted")
    }

    func testRemoteClone() throws {}
}
