//
//  BoneReader.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Files

public class BoneReader {
    public let source: Folder
    
    public init(source: Folder) {
        self.source = source
    }
    
    public func read(from path: BonePath, context: BoneContext) throws -> String {
        let relativePath = try path.to.resolved(with: context)
        let file = try source.file(atPath: relativePath)
        return try file.readAsString(encoding: .utf8)
    }
}
