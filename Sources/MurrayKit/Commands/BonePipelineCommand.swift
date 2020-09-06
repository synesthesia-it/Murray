//
//  BonePipelineCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Files
import Foundation
public class BonePipelineCommand: Command {
    let boneName: String
    let context: JSON
    let pipeline: BonePipeline

    public var folder: Folder = .current

    public init(boneName: String, mainPlaceholder: String, contextString: String = "{}", params: [String] = []) throws {
        guard let jsonConversion = try? JSONSerialization.jsonObject(with: contextString.data(using: .utf8) ?? Data(), options: []) as? JSON else {
            throw CustomError.invalidJSONString
        }
        pipeline = try BonePipeline(folder: folder, murrayFileName: MurrayFile.fileName, pluginManager: .shared)
        let placeholder = pipeline.murrayFile.mainPlaceholder ?? MurrayFile.defaultPlaceholder
        var context: JSON = jsonConversion.reduce([placeholder: mainPlaceholder]) { accumulator, tuple in
            var accumulator = accumulator
            accumulator[tuple.key] = tuple.value
            return accumulator
        }
        params.map {
            $0.split(separator: ":", maxSplits: 1)
        }
        .filter { $0.count == 2 }
        .map { $0.map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) } }
        .compactMap { array -> (key: String, value: String)? in
            guard let key = array.first,
                let value = array.last else { return nil }
            return (key: key, value: value)
        }
        .forEach { context[$0.key] = $0.value }
        self.boneName = boneName
        self.context = context
    }

    public func execute() throws {
        try pipeline.execute(boneName: boneName, with: context)
    }
}
