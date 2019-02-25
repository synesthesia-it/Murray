//
//  PluginTests.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 23/02/2019.
//

import Foundation

import Foundation
import Quick
import Nimble
import Files

@testable import MurrayKit

class PluginsSpec: QuickSpec {
    override func spec() {
        
        it("test") {
            PluginManager.bones()
                .forEach { plugin in
                    plugin.finalize(context: BonePluginContext(boneSpec: nil, currentBone: nil, context: [:]))
            }
        }
    }
}
