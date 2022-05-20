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
}

struct Scenario {
    let name: String
    let murrayFile: Murrayfile

    func make() throws -> Folder {
        let origin = try Folder.mock(at: name)

        let destinationParent = try Folder
            .temporary
            .createSubfolderIfNeeded(withName: "Murray")

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
    private static func simpleMock(type: String) -> Murrayfile {
        .init(packages: ["Murray/Simple/Simple.\(type)"],
              environment: [
                  "author": "Stefano Mondino",
                  "customName": "{{name}}",
                  "nestedName": "{{customName}}",
              ],
              mainPlaceholder: "name",
              plugins: ["shell":
                  ["after":
                      ["echo test >> plugin.data"]]])
    }

    static var simpleJSON: Scenario {
        .init(name: "SimpleJSON",
              murrayFile: simpleMock(type: "json"))
    }

    static var simpleYaml: Scenario {
        .init(name: "SimpleYaml",
              murrayFile: simpleMock(type: "yml"))
    }
}
