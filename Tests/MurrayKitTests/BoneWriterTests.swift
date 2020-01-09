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

class BoneWriterSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BoneWriter")
        
        context("a BoneWriter object") {
            describe("created with default parameters") {
            
            var writer: BoneWriter!
            var item: ConcreteBoneItem!
                beforeEach {
                    
                    try! root.empty()
                    item = ConcreteBoneItem(contents: "{{ name }}TemplateTest;", folder: root, path: BonePath(from: "./", to: "output/{{name}}.swift"))
                    writer = BoneWriter(destination: root)
                    
                }
                it("should write resolved items to proper destination") {
                  
                    expect {
                        let context = ["name": "Custom"]
                        let file = try writer.write(item.contents, to: item.path, context: context)
                        expect { try file.readAsString() } == item.resolved(with: context)
                        return file
                    }
                    .notTo(throwError())
                    
                }
            }
        }
    }
}



