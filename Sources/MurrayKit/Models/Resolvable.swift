//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//

import Foundation

public protocol Resolvable {
    func resolve(with context: Template.Context) throws -> String
}

extension String: Resolvable {
    public func resolve(with context: Template.Context) throws -> String {
        try Template(self, context: context)
            .resolve(recursive: true)
    }
}
//
//extension CodableFile: Resolvable {
//    public func resolve(with context: Template.Context) throws -> String {
//        try file.resolve(with: context)
//    }
//}
//
//extension File: Resolvable {
//    public func resolve(with context: Template.Context) throws -> String {
//        try Template(self, context: context).resolve()
//    }
//}
