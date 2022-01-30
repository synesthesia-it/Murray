//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Foundation

public protocol Encoder {
    func encode<Value: Encodable>(_ object: Value) throws -> Data
}
