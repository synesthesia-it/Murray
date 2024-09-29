//
//  Pipeline.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public struct Pipeline {
    let murrayfile: CodableFile<Murrayfile>
    let procedures: [PackagedProcedure]
    public let context: Template.Context

    public init(murrayfile: CodableFile<Murrayfile>,
                procedure: PackagedProcedure,
                context: Parameters) throws {
        try self.init(murrayfile: murrayfile, procedures: [procedure], context: context)
    }

    public init(murrayfile: CodableFile<Murrayfile>,
                procedures: [PackagedProcedure],
                context: Parameters) throws {
        self.murrayfile = murrayfile
        self.procedures = procedures
        self.context = Template.Context(context, environment: murrayfile.object.enrichedEnvironment)
    }

    public init(murrayfile: CodableFile<Murrayfile>,
                procedure procedureName: String,
                context: Parameters) throws {
        try self.init(murrayfile: murrayfile, procedures: [procedureName], context: context)
    }

    public init(murrayfile: CodableFile<Murrayfile>,
                procedures procedureNames: [String],
                context: Parameters) throws {
        self.murrayfile = murrayfile

        let packages = try murrayfile.packages()
        procedures = try procedureNames.compactMap { procedureName in
            let procedures = packages
                .compactMap { try? PackagedProcedure(package: $0, procedureName: procedureName) }
            switch procedures.count {
            case 0: throw Errors.procedureNotFound(name: procedureName)
            case 1: return procedures.first
            default: throw Errors.multipleProceduresFound(name: procedureName)
            }
        }

        self.context = Template.Context(context, environment: murrayfile.object.enrichedEnvironment)
    }

    public func missingParameters() throws -> [Item.Parameter] {
        try requiredParameters()
            .filter { self.context[$0.name] == nil }
    }

    public func invalidParameters() throws -> [Item.Parameter] {
        try allParameters()
            .filter { parameter in
                if let allowedValues = parameter.values,
                   let contextValue = self.context[parameter.name]?.description {
                    return !Set(allowedValues).contains(contextValue)
                } else {
                    return false
                }
            }
    }

    public func requiredParameters() throws -> [Item.Parameter] {
        try allParameters().filter { $0.isRequired }
    }

    public func allParameters() throws -> [Item.Parameter] {
        try procedures.flatMap { procedure in
            try procedure.items()
                .flatMap {
                    $0.object.parameters
                }
        }.uniqued()
    }

    public func run() throws {
        let missingParameters = try missingParameters()
        if !missingParameters.isEmpty {
            throw Errors
                .missingRequiredParameters(missingParameters)
        }
        let invalidParameters = try invalidParameters()
        if !invalidParameters.isEmpty {
            throw Errors
                .invalidParameters(invalidParameters)
        }
        guard let destinationFolder = murrayfile.file.parent else {
            // no destination folder provided
            throw Errors.unknown
        }
        let manager = PluginManager.shared
        try manager.execute(.init(element: murrayfile.object,
                                  context: context,
                                  phase: .before,
                                  root: destinationFolder))
        try procedures.forEach { procedure in
            let procedureContext = context.adding(procedure.customParameters())
            try manager.execute(.init(element: procedure.procedure,
                                      context: procedureContext,
                                      phase: .before,
                                      root: destinationFolder))
            try procedure.items().forEach { item in

                let itemContext = procedureContext.adding(item.customParameters())

                try manager.execute(.init(element: item.object,
                                          context: itemContext,
                                          phase: .before,
                                          root: destinationFolder))

                try item.writeableFiles(context: context,
                                        destinationRoot: destinationFolder).forEach { file in
                    let enrichedContext = file.enrichedContext(from: itemContext)
                    switch file.reference {
                    case let path as Item.Path:
                        let localContext = enrichedContext.adding(path.customParameters())
                        try manager.execute(.init(element: path,
                                                  context: localContext,
                                                  phase: .before,
                                                  root: destinationFolder))

                        try file.commit(context: localContext)

                        try manager.execute(.init(element: path,
                                                  context: localContext,
                                                  phase: .after,
                                                  root: destinationFolder))

                    case let replacement as Item.Replacement:
                        let localContext = enrichedContext.adding(replacement.customParameters())
                        try manager.execute(.init(element: replacement,
                                                  context: localContext,
                                                  phase: .before,
                                                  root: destinationFolder))
                        try file.commit(context: localContext)
                        try manager.execute(.init(element: replacement,
                                                  context: localContext,
                                                  phase: .after,
                                                  root: destinationFolder))

                    default:
                        try file.commit(context: enrichedContext)
                    }
                }

                try manager.execute(.init(element: item.object,
                                          context: itemContext,
                                          phase: .after,
                                          root: destinationFolder))
            }

            try manager.execute(.init(element: procedure.procedure,
                                      context: procedureContext,
                                      phase: .after,
                                      root: destinationFolder))
        }
        try manager.execute(.init(element: murrayfile.object,
                                  context: context,
                                  phase: .after,
                                  root: destinationFolder))
    }

    public func writeableFiles() throws -> [WriteableFile] {
        guard let destinationFolder = murrayfile.file.parent else {
            // no destination folder provided
            throw Errors.unknown
        }
        return try procedures.flatMap {
            try $0.writeableFiles(context: context,
                                  destinationFolder: destinationFolder)
        }
    }
}
