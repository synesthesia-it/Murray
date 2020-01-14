//
//  BoneContext.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation

public struct BoneContext {
    public let context: JSON
    public init(_ values: JSON, environment: JSON = [:]) {
        context = environment.merging(values, uniquingKeysWith: { e, v in return v })
    }
}
