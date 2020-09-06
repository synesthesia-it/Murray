//
//  PluginManager.swift
//  Commander
//
//  Created by Stefano Mondino on 20/01/2020.
//

import Files
import Foundation
import Gloss
open class Plugin {
    open var name: String { return "" }

    open class func getInstance() -> Plugin { return Plugin() }

    public init() {}

    open func execute(phase _: PluginPhase, from _: Folder) throws {}

    open func pluginData<T: JSONDecodable>(for item: BoneItem) -> T? {
        guard let json = item.pluginData[name],
            let data = T(json: json)
        else {
            return nil
        }
        return data
    }
}

public enum PluginPhase {
    case beforeItemReplace(item: ObjectReference<BoneItem>, context: BoneContext)
    case afterItemReplace(item: ObjectReference<BoneItem>, context: BoneContext)
}

public class PluginManager {
    public static let shared = PluginManager()

    public static var defaultPlugins: [Plugin] = [XCodePlugin()]

    public let plugins: [Plugin]

    public init(defaultPlugins: [Plugin] = defaultPlugins) {
        plugins = defaultPlugins
    }

    public func execute(phase: PluginPhase, from folder: Folder) throws {
        try plugins.forEach { try $0.execute(phase: phase, from: folder) }
    }
}
