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

class BoneProcedureSpec: QuickSpec {
    override func spec() {
        context("a BoneProcedure object") {
            describe("created with default parameters") {
                it("should not error") {
                    let bone = BoneProcedure(json: .from(Mocks.BoneProcedure.simple))
                    expect(bone).notTo(beNil())
                    expect(bone?.name) == "simpleGroup"
                    expect(bone?.itemPaths).to(haveCount(1))
                    expect(bone?.itemPaths.first) == "SimpleItem/SimpleItem.json"
//                    expect(bone?.itemPaths.last) == "customBone2"
                }
            }
        }
    }
}


