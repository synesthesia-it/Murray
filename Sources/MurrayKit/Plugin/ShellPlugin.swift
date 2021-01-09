//
//  XCodePlugin.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 21/01/2020.
//

import Files
import Foundation
import Gloss
import ShellOut

open class ShellPlugin: Plugin {
    override open var name: String { return "shell" }

    struct PluginData: JSONDecodable {
        let before: [String]?
        let after: [String]?
        init?(json: JSON) {
            before = ("before" <~~ json) ?? []
            after = ("after" <~~ json) ?? []
        }
    }

    override open func execute(phase: PluginPhase, from folder: Folder, defaultData _: [String: JSON]) throws {
        switch phase {
        case let .beforeItemReplace(item, context):
            try process(item: item.object, keyPath: \.before, projectFolder: folder, context: context)
        case let .afterItemReplace(item, context):
            try process(item: item.object, keyPath: \.after, projectFolder: folder, context: context)
        case let .beforeProcedureReplace(procedure, context):
            try process(item: procedure, keyPath: \.before, projectFolder: folder, context: context)
        case let .afterProcedureReplace(procedure, context):
            try process(item: procedure, keyPath: \.after, projectFolder: folder, context: context)
        case let .beforePathReplace(item, context):
            try process(item: item, keyPath: \.before, projectFolder: folder, context: context)
        case let .afterPathReplace(item, context):
            try process(item: item.object, keyPath: \.after, projectFolder: folder, context: context)
        }
    }

    func process(item: PluginDataContainer, keyPath: KeyPath<PluginData, [String]?>, projectFolder: Folder, context: BoneContext) throws {
        Logger.log("Attempting to process item '\(item.name)' with context: \(context)", level: .verbose)
        guard let data: PluginData = pluginData(for: item) else { return }
        let commands = try (data[keyPath: keyPath] ?? []).map { try $0.resolved(with: context) }
        guard !commands.isEmpty else { return }
        commands.forEach { command in
            Logger.log(command)
            do {
                try shellOut(to: command, at: projectFolder.path)
            } catch {
                Logger.log("Error executing command \(command)")
            }
        }
    }
}
