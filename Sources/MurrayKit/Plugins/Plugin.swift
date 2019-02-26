//
//  Plugin.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 23/02/2019.
//

import Foundation
import Files

public class Plugin {
    public var pluginName: String { return "" }
    public init() {}
    public static func getInstance() -> Plugin { return Plugin() }
}

public struct BonePluginContext {
    public let boneSpec: BoneSpec?
    public let currentBone: BoneItem?
    public let name: String?
    public let context: [String: Any]
    init(boneSpec: BoneSpec? = nil, currentBone: BoneItem? = nil,name: String? = nil, context:[String: Any] = [:]) {
        self.boneSpec = boneSpec
        self.currentBone = currentBone
        self.context = context
        self.name = name
    }
}

public protocol BonePlugin {
    func initializeBones(context: BonePluginContext) throws
    func beforeReplace(context: BonePluginContext, file: File) throws
    func afterReplace(context: BonePluginContext, file: File) throws
    func finalizeBones(context: BonePluginContext) throws
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
    static func initializeBones(context: BonePluginContext) throws {
       try bones().forEach { try $0.initializeBones(context: context) }
    }
    static func beforeReplace(context: BonePluginContext, file: File) throws {
       try bones().forEach { try $0.beforeReplace(context: context, file: file) }
    }
    static func afterReplace(context: BonePluginContext, file: File) throws {
       try bones().forEach { try $0.afterReplace(context: context, file: file) }
    }
    static func finalizeBones(context: BonePluginContext) throws {
       try bones().forEach { try $0.finalizeBones(context: context) }
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
