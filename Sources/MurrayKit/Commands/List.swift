//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation

public struct List {
    public let murrayfile: CodableFile<Murrayfile>

    public init(murrayfile: CodableFile<Murrayfile>) throws {
        self.murrayfile = murrayfile
    }

    public init(folder: Folder,
                murrayfileName: String = Murrayfile.defaultName)
        throws {
        let murrayfile = try CodableFile(in: folder, murrayfileName: murrayfileName)
        try self.init(murrayfile: murrayfile)
    }

    public func list() throws -> [PackagedProcedure] {
        try murrayfile.packages()
            .flatMap { package in
                package.object
                    .procedures
                    .map { .init(package: package,
                                 procedure: $0) }
            }
    }
}
