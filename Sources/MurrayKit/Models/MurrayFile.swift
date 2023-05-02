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

    private func string(from date: Date, format: String = "dd/MM/yyyy") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }

    private var customParameters: [String: AnyHashable] {
        let author = (try? Process().launchBash(with: "git config user.name",
                                                outputHandle: nil))?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return ["_date": string(from: date),
                "_dateTime": string(from: date, format: "dd/MM/yyyy HH:mm:ss"),
                "_timestamp": String(Int64(Date().timeIntervalSince1970)),
                "_time": string(from: date, format: "MM:ss"),
                "_year": string(from: date, format: "yyyy"),
                "_author": author ?? ""]
    }

    private let date: Date = .init()
    public private(set) var packages: [String]
    private var environment: Parameters
    public var enrichedEnvironment: Parameters {
        let environmentDictionary = customParameters
            .merging(environment.dictionaryValue ?? [:],
                     uniquingKeysWith: { _, original in original })
        return .init(environmentDictionary)
    }

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
