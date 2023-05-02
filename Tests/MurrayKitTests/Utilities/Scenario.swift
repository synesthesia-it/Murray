//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
@testable import MurrayKit

extension Folder {
    static func mock(at name: String = "") throws -> Folder {
        try Folder(path: Bundle.module.resourcePath ?? Bundle.module.bundlePath)
            .subfolder(at: "Mocks/\(name)")
    }

    static func testFolder() throws -> Folder {
        try Folder
            .temporary
            .createSubfolderIfNeeded(withName: "Murray")
    }

    static func emptyTestFolder() throws -> Folder {
        try? Folder.temporary.subfolder(named: "emptyTest").delete()
        return try Folder
            .temporary
            .createSubfolderIfNeeded(withName: "emptyTest")
    }
}

struct Scenario {
    let name: String

    func make() throws -> Folder {
        let origin = try Folder.mock(at: name)

        let destinationParent = try Scenario.folder()

        try? destinationParent
            .subfolder(named: name)
            .delete()

        try origin
            .copy(to: destinationParent)

        let destination = try destinationParent
            .subfolder(named: name)
        print("Running in \(destination)")
        return destination
    }
}

extension Scenario {
    static var simpleJSON: Scenario {
        .init(name: "SimpleJSON")
    }

    static var simpleYaml: Scenario {
        .init(name: "SimpleYaml")
    }

    static var wrongMurrayfile: Scenario {
        .init(name: "WrongMurrayfile")
    }

    static var cloneOrigin: Scenario {
        .init(name: "Skeleton")
    }

    static var cloneOriginInSubfolder: Scenario {
        .init(name: "SkeletonInSubfolder")
    }

    static func folder() throws -> Folder {
        try Folder.testFolder()
    }
}
