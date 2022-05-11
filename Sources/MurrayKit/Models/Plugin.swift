//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public protocol PluginDataContainer {
    var name: String { get }
    var pluginData: JSON { get }
}
