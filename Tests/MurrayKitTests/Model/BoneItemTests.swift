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

class BoneItemSpec: QuickSpec {
    override func spec() {
        context("a BoneItem object") {
            describe("created with default parameters") {
                it("should not error") {
                    let bone = BoneItem(json: .from(self.simpleBone))
                    expect(bone).notTo(beNil())
                    expect(bone?.name) == "simpleBone"
                    expect(bone?.paths).to(haveCount(1))
                    expect(bone?.parameters).to(haveCount(2))
                    expect(bone?.parameters.first?.name) == "name"
                    expect(bone?.parameters.first?.isRequired) == true
                    expect(bone?.parameters[1].isRequired) == false
                }
            }
        }
    }
}
extension JSON {
    static func from(_ string: String) -> JSON {
        return try! JSONSerialization.jsonObject(with: string.data(using: .utf8)!, options: []) as! JSON
    }
}
extension BoneItemSpec {
    
    var simpleBone: String { """
        {
            "name": "simpleBone",
            "paths": [
                { "from": "path/from/bone.swift",
                  "to": "path/to/{{ name }}/{{ name }}.swift"
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
