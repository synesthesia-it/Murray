//
//  BonePipelineCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import MurrayKit
import Files
public class BonePipelineCommand: Command {
    let boneName: String
    let context: JSON
    
    public init(boneName: String, mainPlaceholder: String, contextString: String = "{}", params: [String] = []) throws {
        guard let jsonConversion = try? JSONSerialization.jsonObject(with: contextString.data(using: .utf8) ?? Data(), options: []) as? JSON else {
            throw Errors.invalidJSONString
        }
        var context:JSON = jsonConversion.reduce(["name": mainPlaceholder]) { a, t in
            var accumulator = a
            accumulator[t.key] = t.value
            return accumulator
        }
        
        params.map {
            $0.components(separatedBy: ":")
        }
        .filter { $0.count == 2}
        .map { $0.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}}
        .compactMap {array -> (key: String, value:String)? in
            guard let key = array.first,
                let value = array.last else { return nil }
            return (key: key, value: value)}
            .forEach {
                context[$0.key] = $0.value
        }
        self.boneName = boneName
        self.context = context
    }
    
    public func execute() throws {
        
        let pipeline = try BonePipeline(folder: Folder.current, murrayFileName: "Murrayfile.json", pluginManager: .shared)
        try pipeline.execute(boneName: boneName, with: context)
    }
}
