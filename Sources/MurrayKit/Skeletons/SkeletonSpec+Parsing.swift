//
//  SkeletonSpec+Parsing.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files

extension SkeletonSpec {
    
    static func parse(from folder: Folder) throws -> SkeletonSpec {
        Logger.log("Looking for Spec", level: .verbose)
        
        guard let spec = try? folder.file(named: "Skeletonspec.json") else {
            throw Skeleton.Error.missingSpec
        }
        Logger.log("Reading Spec", level: .verbose)
        guard let data = try? spec.read() else {
            throw Skeleton.Error.missingSpec
        }
        Logger.log("Parsing Spec", level: .verbose)
        
        do {
            let spec = try JSONDecoder().decode(SkeletonSpec.self, from: data)
            return spec
        } catch let error {
            Logger.log(error.localizedDescription, level: .verbose)
            throw Skeleton.Error.invalidSpec
        }
    }
}

