//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation

public struct Murrayfile: Codable, Equatable {
    public init(packages: [String],
                environment: Parameters,
                mainPlaceholder: String? = nil,
                plugins: Parameters? = nil)
    {
        self.packages = packages
        self.environment = environment
        self.mainPlaceholder = mainPlaceholder
        self.plugins = plugins
    }

    public private(set) var packages: [String]
    public private(set) var environment: Parameters
    private var mainPlaceholder: String?
    private var plugins: Parameters?

    public var pluginData: Parameters {
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
