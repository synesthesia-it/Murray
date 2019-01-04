//
//  Dependency+Bones.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files

extension TestDependency {
    var bonespec: String {
        return """
    {
        "version": "0.2",
        "sourcesBaseFolder": "Files",
        "destinationBaseFolder": "",
        "name": "Bones",
        "bones": [
        {
        "name": "test",
        "description": "A test",
        "folderPath": "Sources",
        "createSubfolder": false,
        "targets" : ["Test"],
        "files": ["Bone.swift"]
        }]
        }
"""
    }
    
    var boneTemplate: String {
        return "OK"
    }
    
    func boneSpecTest() throws {
        let fs = FileSystem()
        let murray = fs.currentFolder
        try murray.createFile(named: "Bonespec.json", contents: bonespec)
        let files = try murray.createSubfolder(named: "Files")
        try files.createFile(named: "Bone.swift", contents: boneTemplate)
    }
}
