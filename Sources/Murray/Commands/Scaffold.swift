//
//  File.swift
//
//
//  Created by Stefano Mondino on 19/05/22.
//

import Commander
import Foundation
import MurrayKit

extension Commander.Group {
    private func murrayfile(in folder: Folder, name: String = "murrayfile") {
        command(name,
                Flag("verbose"),
                Option<String?>("format", default: nil, description: .scaffoldFileFormatDescription),
                description: .scaffoldMurrayfileDescription) { verbose, format in
            try withVerbose(verbose) {
                Scaffold
                    .murrayfile(encoding: .init(rawValue: format) ?? .yml, in: folder)
                    .executeAndCatch(verbose: verbose)
            }
        }
    }

    private func skeletonfile(in folder: Folder, name: String = "skeleton") {
        command(name,
                Flag("verbose"),
                Option<String?>("format", default: nil, description: .scaffoldFileFormatDescription),
                description: .scaffoldSkeletonfileDescription) { verbose, format in
            Scaffold
                .skeletonfile(encoding: .init(rawValue: format) ?? .yml, in: folder)
                .executeAndCatch(verbose: verbose)
        }
    }

    private func package(in folder: Folder,
                         name: String = "package") {
        command(name,
                Flag("verbose"),
                Argument<String>("name",
                                 description: .scaffoldPackageNameDescription),

                Option<String>("folder",
                               default: "Murray",
                               description: .scaffoldPackageFolderDescription),

                Option<String?>("format",
                                default: nil,
                                description: .scaffoldFileFormatDescription),
                description: .scaffoldPackageDescription) { verbose, name, path, format in
            Scaffold
                .package(named: name,
                         encoding: .init(rawValue: format),
                         description: .init(format: .scaffoldPackageDefaultDescriptionFormat, name),
                         rootFolder: folder,
                         path: path)
                .executeAndCatch(verbose: verbose)
        }
    }

    private func item(in folder: Folder,
                      name: String = "bone") {
        command(name,
                Flag("verbose"),
                Argument<String>("packageName",
                                 description: .scaffoldItemPackageNameDescription),
                Argument<String>("name",
                                 description: .scaffoldItemNameDescription),
                Flag("skipProcedure",
                     description: .scaffoldItemSkipProcedureDescription),
                Argument<[String]>("files",
                                   description: .scaffoldItemFilesDescription),
                description: .scaffoldItemDescription) { verbose, package, name, skipProcedure, files in
            Scaffold.item(named: name,
                          package: package,
                          description: .init(format: .scaffoldItemDefaultDescriptionFormat, name),
                          rootFolder: folder,
                          createProcedure: !skipProcedure,
                          files: files)
                .executeAndCatch(verbose: verbose)
        }
    }

    private func procedure(in folder: Folder,
                           name: String = "procedure") {
        command(name,
                Flag("verbose"),
                Argument<String>("packageName",
                                 description: .scaffoldProcedurePackageNameDescription),
                Argument<String>("name",
                                 description: .scaffoldProcedureNameDescription),
                Argument<[String]>("itemNames",
                                   description: .scaffoldProcedureItemsDescription),
                description: .scaffoldProcedureDescription) { verbose, package, name, items in
            Scaffold.procedure(named: name,
                               package: package,
                               description: .init(format: .scaffoldProcedureDefaultDescriptionFormat, name),
                               rootFolder: folder,
                               itemNames: items)
                .executeAndCatch(verbose: verbose)
        }
    }

    func scaffoldCommand(in folder: Folder, name: String = "scaffold") {
        group(name) {
            $0.murrayfile(in: folder)
            $0.skeletonfile(in: folder)
            $0.package(in: folder)
            $0.item(in: folder)
            $0.procedure(in: folder)
        }
    }
}
