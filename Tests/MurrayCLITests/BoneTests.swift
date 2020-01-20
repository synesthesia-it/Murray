

import Foundation
import Quick
import Nimble
import Files
import MurrayKit
import Utilities
@testable import MurrayCLI

class BoneTestSpec: QuickSpec {
    override func spec() {
        let root = tempFolder(for: "MurrayCLI")
        let logger: TestLogger = TestLogger(logLevel: .network)
        beforeEach {
            
            Logger.logger = logger
        }
        context("a BoneWriter object") {
            
            describe("created with default parameters") {
                let menu = Menu.menu
                var item: ConcreteFile!
                beforeEach {
                    
                    try! root.empty()
                    try! Mocks.Scenario.simple(from: root)
                    FileManager.default.changeCurrentDirectoryPath(root.path)
                }
                it("should write resolved items to proper destination") {
                    expect {
                        
                        try menu.run(["bone","list"])
                        expect(logger.lastMessage) == "simple.simpleGroup: custom description"
                        return ()
                    }.toNot(throwError())
                    
                }
            }
        }
    }
}
