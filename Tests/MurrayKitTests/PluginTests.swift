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
            try? Plugin.all().forEach {
                $0.finalize(bone: try! Bone(boneName: "test", mainPlaceholder: "test", context: [:]))
            }
        }
    }
}
