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
    public let specPaths: [String]
    
    /**
        A JSON dictionary representing global variables and object that will be resolved by Murray during execution
     
     */
    public let environment: JSON
    
    public let mainPlaceholder: String?
    
    public static var defaultPlaceholder = "name"
    public init() {
        self.specPaths = []
        self.environment = [:]
        self.mainPlaceholder = nil
    }
    public init?(json: JSON) {
        self.specPaths = "specPaths" <~~ json ?? []
        self.environment = "environment" <~~ json ?? [:]
        self.mainPlaceholder = "mainPlaceholder" <~~ json
    }
    
    public func toJSON() -> JSON? {
         return jsonify([
        "specPaths" ~~> specPaths,
        "environment" ~~> environment,
        "mainPlaceholder" ~~> mainPlaceholder
        ])
    }
}
