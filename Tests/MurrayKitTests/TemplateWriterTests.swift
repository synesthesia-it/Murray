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

class TemplateWriterSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "BoneWriter")
        var writer: TemplateWriter!
        context("a BoneWriter object") {
            describe("created with default parameters") {
            
            var item: ConcreteFile!
                beforeEach {
                    
                    try! root.empty()
                    item = ConcreteFile(contents: "{{ name }}TemplateTest;", folder: root, path: BonePath(from: "./", to: "output/{{name}}.swift"))
                    writer = TemplateWriter(destination: root)
                    
                }
                it("should write resolved items to proper destination") {
                    
                    let context = BoneContext(["name": "Custom"])
                    expect {
                        
                        let file = try writer.write(item.contents, to: item.path, context: context)
                        return try file.readAsString()
                        
                    } == item.resolved(with: context)
                }
            }
        }
    }
}


