//
//  BonePipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files

class BonePipeline {
    
    let murrayFile: MurrayFile
    
    let specs: [String:BoneSpec]
    let folder: Folder
    init(folder: Folder, murrayFileName: String = "Murrayfile.json") throws {
        
        guard let file = try folder.file(named: murrayFileName).decodable(MurrayFile.self) else {
            throw Error.generic
        }
        self.folder = folder
        self.murrayFile = file
        
        specs = try file.specPaths
            .compactMap { try folder.decodable(BoneSpec.self, at: $0) }
            .reduce([:]) {
                var specs = $0
                specs[$1.name] = $1
                return specs
        }
        
    }
    
    
    
    func execute(_ boneName: String, with context: BoneContext) throws {
        
//        guard let group = specs.values
//            .flatMap ({ $0.groups })
//            .filter ({ $0.name == boneName })
//                .first else {
//                    throw Error.generic
//        }
        
        
        
        let reader = TemplateReader(source: folder)
//        group.itemPaths.map {
//
//        }
    }
}


