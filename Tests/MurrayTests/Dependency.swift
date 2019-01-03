//
//  Dependency.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 03/01/2019.
//

import Foundation
import MurrayKit
import Files
class TestDependency: Dependency {
    func cloneProject(from git:URL) throws {
        let fs = FileSystem()
        try! fs.createFolder(at: "Skeleton")
        try! fs.createFolder(at: "Skeleton/.git")
        print ("faking git clone from \(git)")
    }
}
