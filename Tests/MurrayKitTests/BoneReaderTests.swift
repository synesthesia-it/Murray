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

class BoneReaderSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BoneReader")
        
        context("a BoneReader object") {
            describe("created with default parameters") {
            
            var reader: BoneReader!
            var item: ConcreteBoneItem!
                beforeEach {
                    
                    try! root.empty()
                    item = ConcreteBoneItem(contents: "{{ name }}TemplateTest;", folder: root, path: BonePath(from: "input/Bone.swift", to: "output/{{name}}.swift"))
                    item.createSource()
                    reader = BoneReader(source: root)
                    
                }
                it("should read template from source") {
                    let context = ["name": "Custom"]
                    expect { try reader.read(from: item.path, context: context) } == item.contents
                }
            }
        }
    }
}



