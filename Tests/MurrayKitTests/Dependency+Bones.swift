//
//  Dependency+Bones.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files

extension TestDependency {
    func bonespec(named name: String) -> String {
        return """
    {
        "version": "0.2",
        "sourcesBaseFolder": "Files",
        "destinationBaseFolder": "",
        "name": "\(name)",
        "bones": [
        {
        "name": "test",
        "description": "A test",
        "folderPath": "Sources",
        "createSubfolder": false,
        "otherFilesRules": [
        {
        "placeholder": "\\n// TEXT TO REPLACE",
        "filePath": "replace.txt",
        "text": "replace {{ name }}"
        }
        ],
        "targets" : ["Test"],
        "files": ["Bone.swift"]
        },
        {
        "name": "testLowercased",
        "description": "A test",
        "folderPath": "Sources",
        "placeholderReplaceRule": "{{ name|firstLowercase }}",
        "createSubfolder": false,
        "targets" : ["Test"],
        "files": ["Bone.swift"]
        },
        {
        "name": "testSubfodler",
        "description": "A test",
        "folderPath": "Sources",
        "folderName": "{{ name|firstUppercase }}Folder",
        "createSubfolder": true,
        "otherFilesRules": [
        {
        "placeholder": "\\n// TEXT TO REPLACE",
        "filePath": "replace.txt",
        "text": "replace {{ name }}"
        }
        ],
        "targets" : ["Test"],
        "files": ["Bone.swift"],
        "isPrivate": true
        }
        ]
        }
"""
    }
    
    var boneTemplate: String {
        return "Some template with a {{ name }} placeholder, also uppercased {{ name|uppercase }} and with global {{ mainPlaceholder }}"
    }
    

    
    var jsonTemplate: String {
        return """
        import Foundation
        
        struct {{ name }}: Codable {
        {% for key, value in json %}
        let {{ key|firstLowercase }}: {{ value|swiftType }}
        {% endfor %}
            enum CodingKeys: String, CodingKey {
            {% for key, value in json %}
                case {{ key|firstLowercase }} = "{{ key }}"
            {% endfor %}
            }
        }
        """
    }
    
    func templateResolved(with name: String, customPlaceholder: String = "PLACEHOLDER") -> String {
        return boneTemplate
            .replacingOccurrences(of: "{{ name }}", with: name)
            .replacingOccurrences(of: "{{ name|uppercase }}", with: name.uppercased())
            .replacingOccurrences(of: "{{ mainPlaceholder }}", with: customPlaceholder)
    }
//    func boneSpecTest() throws {
//        try boneSpecTest(named: "testA")
//        try boneSpecTest(named: "testB")
//    }
    func boneSpecTest(named name: String) throws {
        let fs = FileSystem()
        try fs.currentFolder.parent?.createFile(named: "Skeletonspec.json", contents: skeletonSpec)
        try fs.currentFolder.parent?.createFile(named: "replace.txt", contents: "\n// TEXT TO REPLACE")
        let bones = try fs.currentFolder.createSubfolder(named: name)
        try bones.createFile(named: "Bonespec.json", contents: bonespec(named: name))
        let files = try bones.createSubfolder(named: "Files")
        try files.createFile(named: "Bone.swift", contents: boneTemplate)
        
    }
    func boneSpecJSONTest(named name: String) throws {
        let fs = FileSystem()
        try fs.currentFolder.parent?.createFile(named: "Skeletonspec.json", contents: skeletonSpec)
        let bones = try fs.currentFolder.createSubfolder(named: name)
        try bones.createFile(named: "Bonespec.json", contents: bonespec(named: name))
        let files = try bones.createSubfolder(named: "Files")
        try files.createFile(named: "Bone.swift", contents: jsonTemplate)
    }
}
