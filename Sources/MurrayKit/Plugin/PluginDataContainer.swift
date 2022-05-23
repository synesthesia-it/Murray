//
//  File.swift
//  
//
//  Created by Stefano Mondino on 23/05/22.
//

import Foundation

public protocol PluginDataContainer {
    var pluginData: Parameters? { get }
}

extension Murrayfile: PluginDataContainer {}
extension Item: PluginDataContainer {}
extension Item.Path: PluginDataContainer {}
extension Item.Replacement: PluginDataContainer {}
extension Procedure: PluginDataContainer {}
