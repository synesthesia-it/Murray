//
//  Bone.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 16/07/18.
//

import Foundation
import Rainbow
class BoneList : Codable {
    
    class Bone : Codable {
        
        var name = ""
        var description : String { return _description ?? "" }
        var files:[String] { return _files ?? [] }
        var subBones:[String] { return _subBones ?? [] }
        var folders:[String] { return _folderPath?.components(separatedBy:"/") ?? [] }
        var placeholder:String { return _placeholder ?? "Bone" }
        var targetNames:[String] { return _targetNames ?? [] }
        var createSubfolder:Bool { return _createSubfolder ?? true }
        
        private var _createSubfolder:Bool?
        private var _subBones: [String]?
        private var _files: [String]?
        private var _folderPath: String?
        private var _description:String?
        private var _placeholder:String?
        private var _targetNames:[String]?
        
        enum CodingKeys : String, CodingKey {
            case _subBones = "subBones"
            case _files = "files"
            case _folderPath = "folderPath"
            case _placeholder = "placeholder"
            case _description = "description"
            case _targetNames = "targets"
            case _createSubfolder = "createSubfolder"
        }
    }
    
    var bones: [String:Bone]
    var sourcesBaseFolder: String = ""
    
    enum CodingKeys : String, CodingKey {
        case bones
        case sourcesBaseFolder
    }
    
    var printableDescription : String {
        return self.bones
            .map { [$0.key.green, $0.value.description]
                .compactMap{$0}
                .joined(separator: " - ") }
            .joined(separator: "\n\n")
    }
    
}
