//
//  PluginManager.swift
//  Commander
//
//  Created by Stefano Mondino on 20/01/2020.
//

import Foundation
import Files
import Gloss
open class Plugin {
    open var name: String { return "" }
    
    open class func getInstance() -> Plugin { return Plugin() }
    
    public init() {}
    
    open func execute(phase: PluginPhase, from folder: Folder) throws {}
    
    open func pluginData<T: JSONDecodable>(for item: BoneItem) -> T? {
        guard let json = item.pluginData[name],
            let data = T.init(json: json) else {
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
    
    static var defaultPlugins: [Plugin] = [XCodePlugin()]
    
    let plugins: [Plugin]
    
    init(defaultPlugins: [Plugin] = defaultPlugins) {
        self.plugins = defaultPlugins
    }
    
    func execute(phase: PluginPhase, from folder: Folder) throws {
        try plugins.forEach { try $0.execute(phase: phase, from: folder) }
    }
    
}
