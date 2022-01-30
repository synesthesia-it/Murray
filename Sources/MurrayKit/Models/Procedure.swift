//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Procedure: Codable {
    public let name: String
    public let description: String
}

public struct PackagedProcedure {
    public let package: CodableFile<Package>
    public let procedure: Procedure
}
