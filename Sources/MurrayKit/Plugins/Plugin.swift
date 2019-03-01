//
//  Plugin.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 23/02/2019.
//

import Foundation
import Files

open class Plugin {
    open var pluginName: String { return "" }
    public init() {}
    open class func getInstance() -> Plugin { return Plugin() }
    
    open func initializeBones(context: BonePluginContext) throws {}
    open func beforeReplace(context: BonePluginContext, file: File) throws {}
    open func afterReplace(context: BonePluginContext, file: File) throws {}
    open func finalizeBones(context: BonePluginContext) throws {}
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




struct PluginManager {
    static func bones() throws -> [Plugin] {
        return try all()
    }
    
    static func local() -> [Plugin] {
        return [XcodePlugin.getInstance()]
    }
    
    static func all() throws -> [Plugin] {
        let path = "~/.murray/Plugins"
        Logger.log("Exploring \(path), looking for plugins", level: .verbose, tag: nil)
        guard let folder = try? Folder(path: path) else {
            Logger.log("No plugins found in \(path)", level: .verbose, tag: nil)
            return []
//            throw PluginError.pluginNotFound
        }
        
//        return []
        return folder.files
            .filter { $0.extension == "dylib" }
            .compactMap { $0.path }
            //.compactMap { Bundle(path: $0.path)?.executablePath }
            .compactMap { LoadPlugin(dylib: $0)?.getInstance() }
        + local()
    }
}

extension PluginManager {
    static func initializeBones(context: BonePluginContext) throws {
       try bones().forEach {
        Logger.log("Initializing \($0.pluginName)", level: .verbose, tag: nil)
        try $0.initializeBones(context: context) }
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
    Logger.log("Trying to load \(dylib)", level: .verbose, tag: nil)
    guard let handle = dlopen(dylib, RTLD_NOW) else {
        Logger.log("Failed to load \(dylib)", level: .verbose, tag: nil)
        return nil
    }
    
    guard let principalClass = dlsym(handle, "mainClass") else {
         Logger.log("Failed to load main class of \(dylib)", level: .verbose, tag: nil)
        return nil
    }
    
    let replacement = unsafeBitCast(principalClass,
                                    to: (@convention (c) () -> UnsafeRawPointer).self)
    let cast =  unsafeBitCast(replacement(), to: Plugin.Type.self)
     Logger.log("Successfully loaded \(dylib) as \(cast)", level: .verbose, tag: nil)
    return cast
}


//public extension Plugin {
    enum PluginError: String, Swift.Error, CustomStringConvertible {
        public var description: String {
            return rawValue
        }
        
        case pluginNotFound
    }
//}
