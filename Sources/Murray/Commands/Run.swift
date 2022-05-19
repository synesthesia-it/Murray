//
//  File.swift
//  
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation
import Commander
import MurrayKit
import Files

struct RunCommand: Command {
    
    var folder: Folder
    let mainPlaceholder: String
    let name: String
    let preview: Bool
    let params: [String]
    let verbose: Bool
    
    init(folder: Folder,
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
    
    func context(mainPlaceholderKey: String) -> [String: Any] {
        return params.reduce(into: [mainPlaceholderKey: mainPlaceholder]) { context, pair in
            let elements = pair.components(separatedBy: ":")
            guard elements.count == 2 else { return }
            context[elements[0]] = elements[1]
        }
    }
    
    func execute() throws {
        
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

extension Commander.Group {
    func runCommand(in folder: Folder, name: String = "run") {
        command(name,
                Argument<String>("name",
                                 description: Strings.runNameDescription),
                Argument<String>("mainPlaceholder",
                                 description: Strings.runMainPlaceholderDescription),
                Flag("verbose", description: Strings.verboseDescription),
                Flag("preview", description: Strings.runPreviewDescription),
                Argument<[String]?>("parameters",
                                    description: Strings.runParametersDescription),
                description: Strings.runDescription) { name, mainPlaceholder, verbose, preview, params in
            
            RunCommand(folder: folder,
                       mainPlaceholder: mainPlaceholder,
                       name: name,
                       preview: preview,
                       verbose: verbose,
                       params: params)
            .executeAndCatch(verbose: verbose)
            
        }
    }
}
