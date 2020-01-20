//
//  Utilities+Mocks.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files

import MurrayKit

public struct Mocks {
    
    public struct Murrayfile {
        
        public static func simple(specPath: String = "Murray/Simple/Simple.json") -> String {
            return  """
                {
                    "environment": {
                        "author": "Stefano Mondino"
                    },
                    "specPaths": ["\(specPath)"]
                }
                """
        }
    }
    
    public struct BoneSpec {
        public static var simple: String {
            return """
                {
                    "name": "simple",
                    "description": "Simple bone spec for testing purposes",
                    "groups": [\(Mocks.BoneGroup.simple)]
                }
            """
        }
        public static func singleGroup(named name: String, items:[String]) -> String {
            return """
                {
                    "name": "singleGroup",
                    "description": "Simple bone spec for testing purposes",
            "groups": [\(Mocks.BoneGroup.group(named: name, items: items))]
                }
            """
        }
    }
    
    public struct BoneGroup {
        public static func group(named name: String, items: [String] ) -> String {
            return """
                    {
                        "name": "\(name)",
                        "items": \(items.map{"\($0.firstUppercased())/\($0.firstUppercased()).json"})
                    }
                    """
        }
        public static var simple: String {

            return  """
                {
                    "name": "simpleGroup",
                    "items": ["SimpleItem/SimpleItem.json"]
                }
            """
        }
    }
    
    public struct BoneItem {
        public static let placeholderFileContents = "This is a test\n\(placeholder)\n\nEnjoy"
        public static let placeholder = "//Murray Placeholder"
        public static let placeholderFilePath = "Sources/Files/Default/Test.swift"
        public static let placeholderFilePath2 = "Sources/Files/Default/Test2.swift"
        public static var simple: String { """
               {
                   "name": "simpleItem",
                   "paths": [
                       { "from": "Bone.swift",
                         "to": "Sources/Files/{{ name }}/{{ name }}.swift"
                       }
                   ],
                   "replacements": [
                        {
                            "text": "{{ name }}",
                            "placeholder": "\(placeholder)",
                            "destination": "\(placeholderFilePath)"
                        },
                        {
                            "text": "{{ name }}",
                            "source": "Replacement.swift",
                            "placeholder": "\(placeholder)",
                            "destination": "\(placeholderFilePath2)"
                        }
                    ],
                   "parameters": [
                       {
                       "name": "name",
                       "isRequired": true
                       },
                       {
                       "name": "type"
                       }
                   ]
               }
               """
        }
        public static func customBone(named name: String) -> String { """
            {
                "name": "\(name)",
                "paths": [
                    { "from": "Bone.swift",
                        "to": "Sources/Files/\(name.firstUppercased())/{{name|firstUppercase}}.swift"
                    },
                    { "from": "Bone.xib",
                      "to": "Sources/Files/\(name.firstUppercased())/{{name|firstUppercase}}.xib"
                    }
                ],
                "parameters": [
                    {
                    "name": "name",
                    "isRequired": true
                    },
                    {
                    "name": "type"
                    }
                ]
            }
            """ }
    }
}

public extension Mocks {
    struct Scenario {
        public static func simple(from root: Folder) throws {
            let murrayFile = ConcreteFile(contents: Mocks.Murrayfile.simple(), folder: root, path: BonePath(from: "Murrayfile.json", to: ""))
            murrayFile.createSource()
            
            let boneSpec = ConcreteFile(contents: Mocks.BoneSpec.simple, folder: root, path: BonePath(from: "Murray/Simple/Simple.json", to: ""))
            boneSpec.createSource()
            
            let simpleItem = ConcreteFile(contents: Mocks.BoneItem.simple, folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/SimpleItem.json", to: ""))
            simpleItem.createSource()
            
            let simpleFile = ConcreteFile(contents: "{{name}}Test", folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/Bone.swift", to: ""))
            simpleFile.createSource()
            
            let replacementFile = ConcreteFile(contents: Mocks.BoneItem.placeholderFileContents, folder: root, path: BonePath(from: Mocks.BoneItem.placeholderFilePath, to: ""))
            replacementFile.createSource()
            let replacementFile2 = ConcreteFile(contents: Mocks.BoneItem.placeholderFileContents, folder: root, path: BonePath(from: Mocks.BoneItem.placeholderFilePath2, to: ""))
            replacementFile2.createSource()
            
            let templateFile = ConcreteFile(contents: "testing {{ name }} in place\n", folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/Replacement.swift", to: ""))
            templateFile.createSource()
        }
        
        
        public static func multipleItemsSingleGroup(names: [String], from root: Folder) throws {
            let specPath = "Murray/SingleGroup/SingleGroup.json"
            let murrayFile = ConcreteFile(contents: Mocks.Murrayfile.simple(specPath: specPath), folder: root, path: BonePath(from: "Murrayfile.json", to: ""))
            murrayFile.createSource()
            
            let boneSpec = ConcreteFile(contents: Mocks.BoneSpec.singleGroup(named: "singleGroup", items: names), folder: root, path: BonePath(from: specPath, to: ""))
            boneSpec.createSource()
            
            
            
            names.forEach { name in
                let simpleItem = ConcreteFile(contents: Mocks.BoneItem.customBone(named: name), folder: root, path: BonePath(from: "Murray/SingleGroup/\(name.firstUppercased())/\(name.firstUppercased()).json", to: ""))
                           simpleItem.createSource()
                           
                ConcreteFile(contents: "{{name}}Test - {{ author }}", folder: root, path: BonePath(from: "Murray/SingleGroup/\(name.firstUppercased())/Bone.swift", to: "output/{{name}}.swift")).createSource()
                ConcreteFile(contents: "{{name}}Test", folder: root, path: BonePath(from: "Murray/SingleGroup/\(name.firstUppercased())/Bone.xib", to: "output/{{name}}.swift")).createSource()
            }
            let replacementFile = ConcreteFile(contents: Mocks.BoneItem.placeholderFileContents, folder: root, path: BonePath(from: Mocks.BoneItem.placeholderFilePath, to: ""))
            replacementFile.createSource()
           
        }
    }
}
