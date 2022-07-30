//
//  File.swift
//
//
//  Created by Stefano Mondino on 20/05/22.
//

import Foundation
import Yams

public struct Scaffold: Command {
    private let closure: () throws -> Void

    private init(_ closure: @escaping () throws -> Void) {
        self.closure = closure
    }

    public static func murrayfile(named name: String = Murrayfile.defaultName,
                                  encoding: CodableFile<Murrayfile>.Encoding,
                                  in folder: Folder) -> Scaffold {
        .init {
            let file = Murrayfile.empty
            try CodableFile.create(file,
                                   encoding: encoding,
                                   named: "\(name).\(encoding.rawValue)",
                                   in: folder)
        }
    }

    public static func skeletonfile(named name: String = Skeleton.defaultName,
                                    encoding: CodableFile<Skeleton>.Encoding,
                                    in folder: Folder) -> Scaffold {
        .init {
            let file = Skeleton.empty
            try CodableFile.create(file,
                                   encoding: encoding,
                                   named: "\(name).\(encoding.rawValue)",
                                   in: folder)
        }
    }

    public static func package(named name: String,
                               encoding: CodableFile<Package>.Encoding? = nil,
                               description: String,
                               rootFolder: Folder,
                               path: String = "Murray") -> Scaffold {
        return Scaffold {
            var murrayfile = try CodableFile<Murrayfile>(in: rootFolder)

            let encoding = encoding ?? murrayfile.encoding()

            let package = Package(name: name,
                                  description: description,
                                  procedures: [])
            let packageName = "\(name).\(encoding.rawValue)"

            let packageStructure = try CodableFile.create(package,
                                                          encoding: encoding,
                                                          named: packageName,
                                                          in: rootFolder.createSubfolderIfNeeded(withName: path).createSubfolderIfNeeded(withName: name))

            let newPath = packageStructure.file.path(relativeTo: rootFolder)

            try murrayfile.update {
                $0.add(packagePath: newPath)
            }
        }
    }

    public static func item(named name: String,
                            package packageName: String,
                            encoding: CodableFile<Item>.Encoding? = nil,
                            description: String,
                            rootFolder: Folder,
                            createProcedure: Bool = true,
                            files: [String]) -> Scaffold {
        Scaffold {
            let murrayfile = try CodableFile<Murrayfile>(in: rootFolder)
            guard var package = try murrayfile
                .packages()
                .first(where: { $0.object.name == packageName }),
                let packageFolder = package.file.parent
            else {
                throw Errors.invalidPackageName(packageName)
            }

            let targetFolder = try packageFolder.createSubfolderIfNeeded(withName: name)
            let encoding = encoding ?? murrayfile.encoding()

            let paths = try files.map {
                try targetFolder
                    .createFileIfNeeded(at: $0)
                    .path(relativeTo: targetFolder)
            }.map { Item.Path(from: $0, to: "") }

            let item = MurrayKit.Item(name: name,
                                      parameters: [],
                                      paths: paths,
                                      plugins: nil,
                                      optionalDescription: description,
                                      replacements: [])
            let fileName = "\(name).\(encoding.rawValue)"

            guard (try? targetFolder.file(named: fileName)) == nil else {
                throw Errors.itemAlreadyExists(name)
            }

            let file = try CodableFile.create(item,
                                              encoding: encoding,
                                              named: fileName,
                                              in: targetFolder)

            if createProcedure {
                let itemRelativePath = file.file.path(relativeTo: packageFolder)
                let procedure = Procedure(name: name,
                                          description: description,
                                          plugins: nil,
                                          itemPaths: [itemRelativePath])
                try package.update {
                    $0.add(procedure: procedure)
                }
            }
        }
    }

    public static func procedure(named name: String,
                                 package packageName: String,
                                 description: String,
                                 rootFolder: Folder,
                                 itemNames: [String]) -> Scaffold {
        Scaffold {
            let murrayfile = try CodableFile<Murrayfile>(in: rootFolder)
            guard var package = try murrayfile
                .packages()
                .first(where: { $0.object.name == packageName }),
                let packageFolder = package.file.parent
            else {
                throw Errors.invalidPackageName(packageName)
            }

            guard package.object
                .procedures
                .first(where: { $0.name.lowercased() == name.lowercased() }) == nil
            else {
                throw Errors.procedureAlreadyExists(name)
            }

            let availableItems = Set(try package.items())
            let itemPaths = try itemNames.map { itemName -> String in
                guard let item = availableItems.first(where: { $0.object.name == itemName }) else {
                    throw Errors.itemNotFound(itemName)
                }
                return item.file.path(relativeTo: packageFolder)
            }

            let procedure = Procedure(name: name,
                                      description: description,
                                      plugins: nil,
                                      itemPaths: itemPaths)

            try package.update {
                $0.add(procedure: procedure)
            }
        }
    }

    public func execute() throws {
        try closure()
    }
}
