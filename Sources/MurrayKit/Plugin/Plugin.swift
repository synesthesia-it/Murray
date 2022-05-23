//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public protocol PluginType {
    var name: String { get }
    func execute(_ execution: PluginExecution<Murrayfile>) throws
    func execute(_ execution: PluginExecution<Procedure>) throws
    func execute(_ execution: PluginExecution<Item>) throws
    func execute(_ execution: PluginExecution<Item.Path>) throws
    func execute(_ execution: PluginExecution<Item.Replacement>) throws
}

public protocol Plugin: PluginType {
    associatedtype PluginData: Codable
    func data(for item: PluginDataContainer) throws -> PluginData?
}

extension Plugin {
    func data(for item: PluginDataContainer) throws -> PluginData? {
        guard let pluginData = item.pluginData,
              let subJSON = pluginData[name]?.dictionaryValue else { return nil }
        let data = try JSONSerialization.data(withJSONObject: subJSON)
        return try JSONDecoder().decode(data)
    }
}
