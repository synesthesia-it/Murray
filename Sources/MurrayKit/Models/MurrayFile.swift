//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Murrayfile: Hashable, RootFile {
    public static var defaultName = "Murrayfile"

    public init(packages: [String],
                environment: Parameters,
                mainPlaceholder: String? = nil,
                plugins: Parameters? = nil) {
        self.packages = packages
        self.environment = environment
        self.mainPlaceholder = mainPlaceholder
        self.plugins = plugins
    }

    public private(set) var packages: [String]
    public private(set) var environment: Parameters
    private var mainPlaceholder: String?
    private var plugins: Parameters?

    public var pluginData: Parameters? {
        plugins
    }

    /// The default parameter used in all commands as main name to be replaced. Defaults to "name"
    public var namePlaceholder: String {
        mainPlaceholder ?? "name"
    }

    public mutating func add(packagePath: String) {
        packages.append(packagePath)
    }

    public static var empty: Murrayfile = .init(packages: [], environment: nil)
}

public extension CodableFile where Object == Murrayfile {

    func packages() throws -> [CodableFile<Package>] {
        try object.packages
            .compactMap { try file.parent?.file(named: $0) }
            .map { try .init(file: $0) }
    }

}
