//
//  BoneFile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Gloss
/**
    A structure defining main Murrayfile.json
 
    The `Murrayfile.json` file should contain all the informations needed by murray to find and execute commands.
 
 */
public struct MurrayFile: Glossy {
    /**
        An array of paths representing `Bonespec.json` **local** references, relative to Murrayfile directory.
     */
    public private(set) var packages: [String]
    
    /**
        A JSON dictionary representing global variables and object that will be resolved by Murray during execution
     
     */
    public let environment: JSON
    
    public let mainPlaceholder: String?

    public static let fileName: String = "Murrayfile.json"

    public static var defaultPlaceholder = "name"
    public init() {
        self.packages = []
        self.environment = [:]
        self.mainPlaceholder = nil
    }
    public init?(json: JSON) {
        self.packages = "packages" <~~ json ?? []
        self.environment = "environment" <~~ json ?? [:]
        self.mainPlaceholder = "mainPlaceholder" <~~ json
    }
    
    public func toJSON() -> JSON? {
         return jsonify([
        "packages" ~~> packages,
        "environment" ~~> environment,
        "mainPlaceholder" ~~> mainPlaceholder
        ])
    }
    
    public mutating func addSpecPath(_ spec: String) {
        self.packages += [spec]
    }
}
