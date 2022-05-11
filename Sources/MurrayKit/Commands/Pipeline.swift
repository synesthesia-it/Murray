//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation
import Files

struct Pipeline {
    let murrayfile: CodableFile<Murrayfile>
    let procedure: PackagedProcedure
    let context: Template.Context
    
    init(murrayfile: CodableFile<Murrayfile>,
         procedure: PackagedProcedure,
         context: Parameters) throws {
        self.murrayfile = murrayfile
        self.procedure = procedure
        self.context = Template.Context(context, environment: murrayfile.object.environment)
    }
    
    init(murrayfile: CodableFile<Murrayfile>,
         procedure procedureName: String,
         context: Parameters) throws {
        self.murrayfile = murrayfile
        guard let procedure = try murrayfile.packages()
            .compactMap ({ package in
                try? PackagedProcedure(package: package, procedureName: procedureName)
            }).first else {
                throw Errors.procedureNotFound(name: procedureName)
            }
        self.procedure = procedure
        self.context = Template.Context(context, environment: murrayfile.object.environment)
    }
    
    func item(named name: String) throws -> CodableFile<Item> {
        guard let file = try procedure.package.file.parent?.file(at: name) else {
            throw Errors.unparsableFile(name)
        }
        return try CodableFile<Item>(file: file)
    }
}

struct Preview {
    let item: CodableFile<Item>
    let context: Template.Context
    
    init(item: CodableFile<Item>, context: Template.Context) {
        self.item = item
        self.context = context
    }
    
//    func filePreview(for path: Item.Path) throws -> String {
//        guard let contents = try item.file.parent?.file(at: path.from) else {
//            throw Errors.unparsableFile(path.from)
//        }
//    }
}


