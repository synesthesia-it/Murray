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
            expect { try PluginManager.initializeBones(context: BonePluginContext()) }.notTo(throwError())
            expect { try PluginManager.finalizeBones(context: BonePluginContext()) }.notTo(throwError())
//            expect { try PluginManager.afterReplace(context: BonePluginContext(), file: File(path: "/tmp/tmp.txt")) }.notTo(throwError())
            
//            PluginManager.bones()
//                .forEach { plugin in
//                    try plugin.finalize(context: BonePluginContext(boneSpec: nil, currentBone: nil, context: [:]))
//            }
        }
    }
}
