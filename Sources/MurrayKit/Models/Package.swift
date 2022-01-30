//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Package: Codable {
    let name: String
    let description: String
    let procedures: [Procedure]
}
