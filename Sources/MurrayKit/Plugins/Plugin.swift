//
//  Plugin.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 23/02/2019.
//

import Foundation
import Files

public protocol Plugin: class {
    
    static func getInstance() -> Plugin
}

public struct BonePluginContext {
    public let boneSpec: BoneSpec?
    public let currentBone: BoneItem?
    public let context: [String: Any]
    init(boneSpec: BoneSpec? = nil, currentBone: BoneItem? = nil, context:[String: Any] = [:]) {
        self.boneSpec = boneSpec
        self.currentBone = currentBone
        self.context = context
    }
}

public protocol BonePlugin: Plugin {
    func initialize(context: BonePluginContext)
    func beforeReplace(context: BonePluginContext)
    func afterReplace(context: BonePluginContext)
    func finalize(context: BonePluginContext)
}


struct PluginManager {
    static func bones() -> [BonePlugin] {
        return (try? all().compactMap {$0 as? BonePlugin}) ?? []
    }
    static func all() throws -> [Plugin] {
        let path = "~/.murray/Plugins"
        guard let folder = try? Folder(path: path) else {
            throw PluginError.pluginNotFound
        }
//        return []
        return folder.subfolders
            .filter { $0.extension == "framework" }
            .compactMap { Bundle(path: $0.path)?.executablePath }
            .compactMap { LoadPlugin(dylib: $0)?.getInstance() }
    }
}

extension PluginManager {
    static func initializeBones(context: BonePluginContext) {
        bones().forEach { $0.initialize(context: context) }
    }
    static func beforeReplace(context: BonePluginContext) {
        bones().forEach { $0.beforeReplace(context: context) }
    }
    static func afterReplace(context: BonePluginContext) {
        bones().forEach { $0.afterReplace(context: context) }
    }
    static func finalizeBones(context: BonePluginContext) {
        bones().forEach { $0.finalize(context: context) }
    }
}
func LoadPlugin(dylib: String) -> Plugin.Type? {
    guard let handle = dlopen(dylib, RTLD_NOW) else {
        return nil
    }
    
    guard let principalClass = dlsym(handle, "mainClass") else {
        return nil
    }
    
    let replacement = unsafeBitCast(principalClass,
                                    to: (@convention (c) () -> UnsafeRawPointer).self)
    return unsafeBitCast(replacement(), to: Plugin.Type.self)
}


//public extension Plugin {
    enum PluginError: String, Swift.Error, CustomStringConvertible {
        public var description: String {
            return rawValue
        }
        
        case pluginNotFound
    }
//}
