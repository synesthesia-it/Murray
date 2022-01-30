//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct List {
    public let murrayfile: CodableFile<Murrayfile>

    public init(murrayfile: CodableFile<Murrayfile>) throws {
        self.murrayfile = murrayfile
    }

    public func list() throws -> [CodableFile<Procedure>] {
        []
    }
}
