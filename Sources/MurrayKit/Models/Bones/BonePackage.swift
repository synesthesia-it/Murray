//
//  BoneSpec.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//


import Foundation
import Gloss

/**
    A structure representing a `BonePackage.json` file.
 
    A BonePackage should contain procedures of items that can easily be reused across projects or simply containing some kind of shared features.
 */
public struct BonePackage: Glossy {

    public static let fileName: String = "BonePackage.json"

    /**
        BonePackage name used to identify different bonespecs
     */
    public let name: String
    /**
        A quick description for this BonePackage
     */
    public let description: String?
    /**
        The groups handled by this BonePackage
     */
    public var procedures: [BoneProcedure] = [] {
        didSet {
            update()
        }
    }
    private var proceduresByName: [String: BoneProcedure] = [:]
    
    public init(name: String, description: String? = nil) {
        self.name = name
        self.description = description ?? "Default description"
        self.procedures = []
        update()
    }
    
    public init?(json: JSON) {
        guard let name:String = "name" <~~ json else { return nil }
        self.name = name
        self.description = "description" <~~ json
        self.procedures = "procedures" <~~ json ?? []
        update()
    }
    mutating func update() {
        proceduresByName = procedures.reduce([:]) { dictionary, procedure in
            var d = dictionary
            d[procedure.name] = procedure
            return d
        }
    }
    public mutating func add(procedure: BoneProcedure) {
        self.procedures = self.procedures.filter { $0.name != procedure.name } + [procedure]
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "description" ~~> description,
            "procedures" ~~> procedures,
        ])
    }

    
    public subscript(group: String) -> BoneProcedure? {
        get { proceduresByName[group] }
    }
    
}
