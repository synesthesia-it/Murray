//
//  Utilities+Mocks.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 13/01/2020.
//

import Foundation
import Files

@testable import MurrayKit

struct Mocks {
    
    struct Murrayfile {
        
        static var simple: String {
            return  """
                {
                    
                    "specPaths": ["Murray/Simple/Simple.json"]
                }
                """
        }
    }
    
    struct BoneSpec {
        static var simple: String {
            return """
                {
                    "name": "simple",
                    "description": "Simple bone spec for testing purposes",
                    "groups": ["simpleGroup"]
                }
            """
        }
    }
    
    struct BoneGroup {
        static var simple: String {

            return  """
                {
                    "name": "simpleGroup",
                    "items": ["simpleBone", "customBone2"]
                }
            """
        }
    }
    
    struct BoneItem {
        static var simple: String { """
               {
                   "name": "simpleItem",
                   "paths": [
                       { "from": "SimpleItem/Bone.swift",
                         "to": "Sources/Files/{{ name }}/{{ name }}.swift"
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
        static func customBone(named name: String) -> String { """
            {
                "name": "\(name)",
                "paths": [
                    { "from": "path/from/bone.swift",
                      "to": "path/to/{{ \(name) }}/{{ \(name) }}.swift"
                    },
                    { "from": "path/from/bone.xib",
                      "to": "path/to/{{ \(name) }}/{{ \(name) }}.xib"
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

extension Mocks {
    struct Scenario {
        static func simple(from root: Folder) throws {
                   let murrayFile = ConcreteFile(contents: Mocks.Murrayfile.simple, folder: root, path: BonePath(from: "Murrayfile.json", to: "output/{{name}}.swift"))
                                murrayFile.createSource()
                                
            //                    let boneFolder = try! templatesFolder.createSubfolderIfNeeded(withName: "Simple")
                                let boneSpec = ConcreteFile(contents: Mocks.BoneSpec.simple, folder: root, path: BonePath(from: "Murray/Simple/Simple.json", to: "output/{{name}}.swift"))
                                boneSpec.createSource()
                                
            //                    let itemFolder = try! boneFolder.createSubfolderIfNeeded(withName: "SimpleItem")
                                
                                let simpleItem = ConcreteFile(contents: Mocks.BoneItem.simple, folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/SimpleItem.json", to: "output/{{name}}.swift"))
                                simpleItem.createSource()
                                
                                let simpleFile = ConcreteFile(contents: "{{name}}Test", folder: root, path: BonePath(from: "Murray/Simple/SimpleItem/Bone.swift", to: "output/{{name}}.swift"))
                                simpleFile.createSource()
        }
    }
}
