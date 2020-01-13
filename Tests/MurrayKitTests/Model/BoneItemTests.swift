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
                    let bone = BoneItem(json: .from(Mocks.BoneItem.simple))
                    expect(bone).notTo(beNil())
                    expect(bone?.name) == "simpleItem"
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

extension BoneItemSpec {
    
   
}
