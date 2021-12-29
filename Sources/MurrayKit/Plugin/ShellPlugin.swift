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
        init?(before: [String], after: [String]) {
            self.before = before.isEmpty ? nil : before
            self.after = after.isEmpty ? nil : after
            if self.before == nil, self.after == nil {
                return nil
            }
        }

        init?(json: JSON) {
            before = ("before" <~~ json)
            after = ("after" <~~ json)
            if before == nil, after == nil {
                return nil
            }
        }

        func adding(defaultData: JSON) -> PluginData {
            guard
                let newData = PluginData(json: defaultData)
            else {
                return self
            }
            return PluginData(before: [newData.before, before].compactMap { $0 }.flatMap { $0 },
                              after: [newData.after, after].compactMap { $0 }.flatMap { $0 }) ?? self
        }
    }

    override open func execute(phase: PluginPhase, from folder: Folder, defaultData: JSON?) throws {
        switch phase {
        case let .beforeItemReplace(item, context):
            try process(item: item.object, keyPath: \.before, projectFolder: folder, context: context, defaultData: nil)
        case let .afterItemReplace(item, context):
            try process(item: item.object, keyPath: \.after, projectFolder: folder, context: context, defaultData: nil)
        case let .beforeProcedureReplace(procedure, context):
            try process(item: procedure, keyPath: \.before, projectFolder: folder, context: context, defaultData: defaultData)
        case let .afterProcedureReplace(procedure, context):
            try process(item: procedure, keyPath: \.after, projectFolder: folder, context: context, defaultData: defaultData)
        case let .beforePathReplace(item, context):
            try process(item: item, keyPath: \.before, projectFolder: folder, context: context, defaultData: nil)
        case let .afterPathReplace(item, context):
            try process(item: item.object, keyPath: \.after, projectFolder: folder, context: context, defaultData: nil)
        }
    }

    func process(item: PluginDataContainer,
                 keyPath: KeyPath<PluginData, [String]?>,
                 projectFolder: Folder, context: BoneContext,
                 defaultData: JSON?) throws {
        Logger.log("Attempting to process item '\(item.name)' with context: \(context)", level: .verbose)
        guard let data = pluginData(for: item, type: PluginData.self)?
            .adding(defaultData: defaultData ?? [:]) ?? PluginData(json: defaultData ?? [:]) else { return }
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
