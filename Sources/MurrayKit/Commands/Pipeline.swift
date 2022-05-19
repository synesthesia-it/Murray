//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
import Files

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
    
//    func item(at path: String, in procedure: PackagedProcedure) throws -> CodableFile<Item> {
//        guard let file = try procedure.package.file.parent?.file(at: path) else {
//            throw Errors.unparsableFile(path)
//        }
//        return try CodableFile<Item>(file: file)
//    }
    
    
    public func run() throws {
        try writeableFiles().forEach {
            try $0.commit(context: self.context)
        }
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
