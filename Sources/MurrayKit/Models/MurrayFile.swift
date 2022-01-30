//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation

public struct Murrayfile: Codable, Equatable {
    public private(set) var packages: [String]
    public private(set) var environment: [String: AnyCodable]
    private var mainPlaceholder: String?
    private var plugins: [String: AnyCodable]?

    public var pluginData: [String: AnyCodable] {
        plugins ?? [:]
    }

    /// The default parameter used in all commands as main name to be replaced. Defaults to "name"
    public var namePlaceholder: String {
        mainPlaceholder ?? "name"
    }
}

public extension CodableFile where Object == Murrayfile {
    init(in folder: Folder, murrayfileName: String = "Murrayfile") throws {
        let extensions = ["", ".json", ".yml", ".yaml"]
        let names = extensions.map { murrayfileName + $0 }
        let file = try folder.firstFile(named: names)
        try self.init(file: file)
    }
}
