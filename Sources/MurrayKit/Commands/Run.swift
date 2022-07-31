//
//  File.swift
//
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation

public struct Run: CommandWithContext {
    var folder: Folder
    public let mainPlaceholder: String
    let name: String
    let preview: Bool
    public let params: [String]
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

    public func execute() throws {
        let murrayfile = try CodableFile<Murrayfile>.init(in: folder)
        let context = context(mainPlaceholderKey: murrayfile.object.namePlaceholder)

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
