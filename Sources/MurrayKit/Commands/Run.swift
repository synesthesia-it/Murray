//
//  File.swift
//
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation

public struct Run: Command {
    var folder: Folder
    let mainPlaceholder: String
    let name: String
    let preview: Bool
    let params: [String]
    let verbose: Bool

    public init(folder: Folder,
                mainPlaceholder: String,
                name: String,
                preview: Bool,
                verbose: Bool,
                params: [String]?) {
        self.folder = folder
        self.mainPlaceholder = mainPlaceholder
        self.name = name
        self.params = params ?? []
        self.preview = preview
        self.verbose = verbose
    }

    func context(mainPlaceholderKey: String) -> JSON {
        return params.reduce(into: [mainPlaceholderKey: mainPlaceholder]) { context, pair in
            let elements = pair.components(separatedBy: ":")
            guard elements.count == 2 else { return }
            context[elements[0]] = elements[1]
        }
    }

    public func execute() throws {
        let murrayfile = try CodableFile<Murrayfile>.init(in: folder)
        let context = self.context(mainPlaceholderKey: murrayfile.object.namePlaceholder)

        let pipeline = try Pipeline(murrayfile: murrayfile,
                                    procedure: name,
                                    context: .init(context))

        let files = try pipeline.writeableFiles()
        if preview {
            try files.forEach { file in
                let contents = try file.preview(context: pipeline.context)
                if verbose {
                    Logger.log("File contents preview:\n\n\(contents)", level: .normal)
                }
            }
        } else {
            Logger.log("Running pipeline '\(name)'")
            try pipeline.run()
        }
    }
}
