//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation
@testable import MurrayKit

struct Scenario {
    let name: String
    let murrayFile: Murrayfile

    func make() throws -> Folder {
        let origin = try Folder(path: Bundle.module.resourcePath ?? Bundle.module.bundlePath)
            .subfolder(at: "Mocks/\(name)")

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
    static var simpleJSON: Scenario {
        .init(name: "SimpleJSON",
              murrayFile: .init(packages: ["Murray/Simple/Simple.json"],
                                environment: [
                                    "author": "Stefano Mondino",
                                    "customName": "{{name}}",
                                    "nestedName": "{{customName}}",
                                ]))
    }

    static var simpleYaml: Scenario {
        .init(name: "SimpleYaml",
              murrayFile: .init(packages: ["Murray/Simple/Simple.yml"],
                                environment: [
                                    "author": "Stefano Mondino",
                                    "customName": "{{name}}",
                                    "nestedName": "{{customName}}",
                                ]))
    }
}
