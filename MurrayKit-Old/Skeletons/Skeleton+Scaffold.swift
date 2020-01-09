//
//  Bone+Setup.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files
import ShellOut

extension Skeleton {
    public static func scaffold() throws {
        let fs = FileSystem()
    
        if (try? SkeletonSpec.parse(from: fs.currentFolder)) ?? nil != nil {
            throw Error.alreadyExistingSpec
        }
        let skeleton = SkeletonSpec()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(skeleton) else {
            throw Error.invalidSpec
        }
        do {
            try fs.currentFolder.createFile(named: "Skeletonspec.json", contents: jsonData)
        } catch {
            throw Error.invalidSpec
        }
        
    }
}
