//
//  File.swift
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
        self.context = Template.Context(context, environment: murrayfile.object.environment)
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
        self.procedures = try procedureNames.map { procedureName in
            guard let procedure = packages
                .compactMap({ try? PackagedProcedure(package: $0, procedureName: procedureName) })
                .first else {
                throw Errors.procedureNotFound(name: procedureName)
            }
            return procedure
        }
        
        self.context = Template.Context(context, environment: murrayfile.object.environment)
    }
    
    public func run() throws {
//        try writeableFiles().forEach {
//            try $0.commit(context: self.context)
//        }
        
        guard let destinationFolder = murrayfile.file.parent else {
            // no destination folder provided
            throw Errors.unknown
        }
        let manager = PluginManager.shared
        try manager.execute(.init(element: murrayfile.object,
                                           context: context,
                                           phase: .before))
        try procedures.forEach { procedure in
            try manager.execute(.init(element: procedure.procedure,
                                               context: context,
                                               phase: .before))
            try procedure.items().forEach { item in
                try manager.execute(.init(element: item.object,
                                                   context: context,
                                                   phase: .before))
                try item.writeableFiles(context: context,
                                        destinationRoot: destinationFolder).forEach { file in
                    switch file.reference {
                    case let path as Item.Path: try manager.execute(.init(element: path,
                                                                          context: context,
                                                                          phase: .before))
                    case let replacement as Item.Replacement: try manager.execute(.init(element: replacement,
                                                                          context: context,
                                                                          phase: .before))
                    default: break
                    }
                    
                    try file.commit(context: context)
                    
                    switch file.reference {
                    case let path as Item.Path: try manager.execute(.init(element: path,
                                                                          context: context,
                                                                          phase: .after))
                    case let replacement as Item.Replacement: try manager.execute(.init(element: replacement,
                                                                          context: context,
                                                                          phase: .after))
                    default: break
                    }
                }
                
                try manager.execute(.init(element: item.object,
                                                   context: context,
                                                   phase: .after))
            }
            
            try manager.execute(.init(element: procedure.procedure,
                                               context: context,
                                               phase: .before))
        }
        try manager.execute(.init(element: murrayfile.object,
                                           context: context,
                                           phase: .after))
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
