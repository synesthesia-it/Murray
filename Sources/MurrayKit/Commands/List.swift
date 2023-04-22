//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct List {
    public let murrayfile: CodableFile<Murrayfile>

    public init(murrayfile: CodableFile<Murrayfile>) {
        self.murrayfile = murrayfile
    }

    public init(folder: Folder,
                murrayfileName: String = Murrayfile.defaultName)
        throws {
        do {
            let murrayfile = try CodableFile<Murrayfile>(in: folder, defaultName: murrayfileName)
            self.init(murrayfile: murrayfile)
        } catch {
            throw Errors.murrayfileNotFound(folder.path)
        }
    }

    public func packages() throws -> [CodableFile<Package>] {
        try murrayfile.packages()
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

extension List: Command {
    public func execute() throws {
        let list = try list()
        let strings = list.map {
            "\($0.package.object.name.lightGreen).\($0.procedure.name.green): \($0.procedure.description)"
        }
        strings.forEach {
            Logger.log($0, level: .normal)
        }
    }
}
