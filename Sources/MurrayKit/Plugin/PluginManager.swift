//
//  File.swift
//  
//
//  Created by Stefano Mondino on 23/05/22.
//

import Foundation

public class PluginManager {
    static let shared: PluginManager = {
        let manager = PluginManager()
        manager.add(plugins: [ShellPlugin(), XcodePlugin()])
        return manager
    }()
    
    private var plugins: [PluginType] = []
    private init() {}
    
    public func add(plugin: PluginType) {
        if !plugins.contains(where: { $0.name == plugin.name} ) {
            add(plugins: [plugin])
        }
    }
    public func add(plugins: [PluginType]) {
        self.plugins += plugins
    }
    
    public func execute(_ execution: PluginExecution<Murrayfile>) throws {
        try plugins.forEach { try $0.execute(execution) }
    }
    public func execute(_ execution: PluginExecution<Procedure>) throws {
        try plugins.forEach { try $0.execute(execution) }
    }
    public func execute(_ execution: PluginExecution<Item>) throws {
        try plugins.forEach { try $0.execute(execution) }
    }
    public func execute(_ execution: PluginExecution<Item.Path>) throws {
        try plugins.forEach { try $0.execute(execution) }
    }
    public func execute(_ execution: PluginExecution<Item.Replacement>) throws {
        try plugins.forEach { try $0.execute(execution) }
    }
    
}
