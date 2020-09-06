import Foundation
import Gloss
/**
    A structure representing a list of file templates to be resolved against BoneContexts and copied to target folders.

 */
public struct BoneItem: Glossy, PluginDataContainer {
    public let name: String
    public private(set) var paths: [BonePath]
    public let parameters: [BoneParameter]
    public let replacements: [BoneReplacement]
    public let pluginData: [String: JSON]

    public static let fileName = "BoneItem.json"

    public init(name: String, files: [String]) {
        self.name = name
        paths = files.map { BonePath(from: $0, to: "") }
        replacements = []
        pluginData = [:]
        parameters = []
    }

    public init?(json: JSON) {
        guard let name: String = "name" <~~ json else { return nil }
        self.name = name
        paths = "paths" <~~ json ?? []
        parameters = "parameters" <~~ json ?? []
        replacements = "replacements" <~~ json ?? []
        pluginData = "plugins" <~~ json ?? [:]
    }

    public mutating func add(path: BonePath) {
        paths += [path]
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "paths" ~~> paths,
            "parameters" ~~> parameters,
            "replacements" ~~> replacements,
            "plugins" ~~> pluginData,
        ])
    }
}

public struct BoneReplacement: Glossy {
    public let placeholder: String
    public let text: String?
    public let sourcePath: String?
    public let destinationPath: String

    public init(placeholder: String, text: String, sourcePath: String? = nil, destinationPath: String) {
        self.placeholder = placeholder
        self.text = text
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
    }

    public init?(json: JSON) {
        guard let placeholder: String = "placeholder" <~~ json,
            let to: String = "destination" <~~ json else { return nil }

        self.placeholder = placeholder
        destinationPath = to
        text = "text" <~~ json
        sourcePath = "source" <~~ json

        if text == nil, sourcePath == nil { return nil }
    }

    public func toJSON() -> JSON? {
        return jsonify([
            "text" ~~> text,
            "destination" ~~> destinationPath,
            "source" ~~> sourcePath,
            "placeholder" ~~> placeholder,
        ])
    }
}
