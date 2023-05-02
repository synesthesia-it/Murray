//
//  File.swift
//
//
//  Created by Stefano Mondino on 23/05/22.
//

import Foundation

struct ShellPlugin: Plugin {
    var name: String { "shell" }

    struct PluginData: Codable {
        let before: [String]?
        let after: [String]?
    }

    func execute<Element: PluginDataContainer>(_ execution: PluginExecution<Element>) throws {
        let keyPath: KeyPath<PluginData, [String]?>
        switch execution.phase {
        case .before: keyPath = \.before
        case .after: keyPath = \.after
        }

        guard let data = try data(for: execution.element),
              let commands = data[keyPath: keyPath]
        else {
            return
        }

        let context = execution.context()
        try commands.map {
            try $0.resolve(with: context)
        }.forEach {
            Logger.log("Executing command: \($0)", level: .verbose)
            try Process().launchBash(with: $0)
        }
    }
}
