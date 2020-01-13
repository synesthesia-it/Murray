//
//  BonePipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files

class BonePipeline {
    struct ObjectWithPath<T> {
        let file: File
        let object: T
    }
    
    let murrayFile: MurrayFile
    
    let specs: [String: ObjectWithPath<BoneSpec>]
    let folder: Folder
    init(folder: Folder, murrayFileName: String = "Murrayfile.json") throws {
        
        guard let file = try folder.file(named: murrayFileName).decodable(MurrayFile.self) else {
            throw Error.generic
        }
        self.folder = folder
        self.murrayFile = file
        
        specs = try file.specPaths
//            .compactMap { try folder.decodable(BoneSpec.self, at: $0) }
            .reduce([:]) {
                var specs = $0
                let file = try folder.file(atPath: $1)
                guard let spec = try file.decodable(BoneSpec.self)
                    else { throw Error.generic }
                specs[spec.name] = ObjectWithPath(file: file, object: spec)
                return specs
        }
        
    }
    
    
    
    func execute(_ boneName: String, with context: BoneContext) throws {
        
        guard let spec = specs.values.first(where: {
            $0.object[boneName] != nil
        }) else {
            throw Error.generic
        }
        
        guard let group = spec.object[boneName] else {
            throw Error.generic
        }
        
        let items = try group.itemPaths.compactMap {
            try spec.file.parent?.file(atPath: $0)
        }.map {
            try ObjectWithPath(file: $0, object: $0.decodable(BoneItem.self))
        }
        try items.forEach {
            let reader = TemplateReader(source: $0.file.parent!)
            try $0.object?.paths.forEach({ (path) in
                let contents = try reader
                    .file(from: path, context: context)
                    .readAsString()
                    .resolved(with: context)
                
                let writer = TemplateWriter(destination: self.folder)
                try writer.write(contents, to: path, context: context)
            })
        }
//        guard let group = specs.values
//            .flatMap ({ $0.groups })
//            .filter ({ $0.name == boneName })
//                .first else {
//                    throw Error.generic
//        }
        
        
        
//        let reader = TemplateReader(source: folder)
//        group.itemPaths.map {
//
//        }
    }
}


