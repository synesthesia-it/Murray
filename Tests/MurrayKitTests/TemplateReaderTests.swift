//
//  BoneItemTest.swift
//  Commander
//
//  Created by Stefano Mondino on 09/01/2020.
//

import Foundation
import Quick
import Nimble
import Files

@testable import MurrayKit

class TemplateReaderSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BoneReader")
        
        context("a BoneReader object") {
            describe("created with default parameters") {
            
            var reader: TemplateReader!
            var item: ConcreteFile!
                beforeEach {
                    
                    try! root.empty()
                    item = ConcreteFile(contents: "{{ name }}TemplateTest;", folder: root, path: BonePath(from: "input/Bone.swift", to: "output/{{name}}.swift"))
                    item.createSource()
                    reader = TemplateReader(source: root)
                    
                }
                it("should read template from source") {
                    let context = BoneContext(["name": "Custom"])
                    expect { try reader.file(from: item.path, context: context) }.notTo(beNil())
                    expect { try reader.string(from: item.path, context: context) } == item.contents
                    
                }
            }
        }
    }
}



