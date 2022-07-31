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
             "git add .",
             "git commit -m \"test\""]
            .forEach {
                try Process().launchBash(with: $0, in: folder)
            }
        
        return folder
    }
    
    private func makeOriginalGit() throws -> Folder {
        try makeGit(in: try Scenario.cloneOrigin.make())
    }
    private func makeSubfolderGit() throws -> Folder {
        return try makeGit(in: try Scenario.cloneOriginInSubfolder.make())
    }
    
    func testSimpleClone() throws {
        Logger.logLevel = .verbose
        let git = try makeOriginalGit()
        let folder = try Scenario.folder()
        let projectName = "LocalGit"
        
        try? folder.subfolder(named: projectName).delete()
        
        let clone = Clone(folder: folder,
                          git: git.path,
                          context: ["name": .init(stringLiteral: projectName)])
        try clone.run()
        
        let projectFolder = try folder.subfolder(named: projectName)
        
        XCTAssertThrowsError(try projectFolder.subfolder(named: ".git"))
        
        XCTAssertThrowsError(try projectFolder.subfolder(named: "{{name}}"))
        
        let resolvedFolder = try projectFolder.subfolder(named: projectName)
        
        XCTAssertEqual(try resolvedFolder.file(named: "HelloLOCALGIT.swift").readAsString(), "Swift LocalGit\n")
        
        XCTAssertEqual(try projectFolder.file(named: "hello.txt").readAsString(), "Hello\n")
        
        XCTAssertThrowsError(try projectFolder.file(named: "Skeleton.yml"))
    }
    
    func testCloneWithSubfolder() throws {
        let git = try makeSubfolderGit()
        
    }
    
    func testRemoteClone() throws {
        
    }
}
