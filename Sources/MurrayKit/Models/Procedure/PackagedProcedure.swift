//
//  File.swift
//
//
//  Created by Stefano Mondino on 14/05/22.
//

import Foundation

/** A procedure with reference to parent Package

 A procedure itself is not represented by a single file, as it's merely contained into a Package.

 Therefore, there's no reference to parent folder containing all the procedure's items.

 This structure is used to keep that kind of reference.

 */
public struct PackagedProcedure: Hashable {
    public let package: CodableFile<Package>
    public let procedure: Procedure

    public init(package: CodableFile<Package>, procedure: Procedure) {
        self.package = package
        self.procedure = procedure
    }

    public init(package: CodableFile<Package>,
                procedureName name: String) throws {
        self.package = package
        let procedures = package
            .object
            .procedures
            .filter { $0.name == name || name == "\(package.object.name).\($0.name)" }
        guard let procedure = procedures.first else {
            throw Errors.procedureNotFound(name: name)
        }
        self.procedure = procedure
    }

    public func items() throws -> [CodableFile<Item>] {
        try procedure.itemPaths.map { try item(at: $0) }
    }

    private func item(at path: String) throws -> CodableFile<Item> {
        guard let file = try package.file.parent?.file(at: path) else {
            throw Errors.unparsableFile(path)
        }
        return try CodableFile<Item>(file: file)
    }

    public func writeableFiles(context: Template.Context,
                               destinationFolder: Folder) throws -> [WriteableFile] {
        try items().flatMap {
            try $0.writeableFiles(context: context,
                                  destinationRoot: destinationFolder)
        }
    }

    public func customParameters() -> JSON {
        ["_procedure": try? procedure.dictionary()]
    }
}
