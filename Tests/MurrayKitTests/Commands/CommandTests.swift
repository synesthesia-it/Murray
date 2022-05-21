//
//  File.swift
//  
//
//  Created by Stefano Mondino on 21/05/22.
//

import Foundation
@testable import MurrayKit
import XCTest

class CommandTests: TestCase {
    
    private struct TestCommand: Command {
        func execute() throws {
            Logger.log("Test", level: .normal)
            Logger.log("TestVerbose", level: .verbose)
        }
    }
    
    func testLogVerboseWhenSpecified() throws {
        TestCommand().executeAndCatch(verbose: true)
        XCTAssertEqual(logger.messages, [.message("Test"), .message("TestVerbose")])
    }
    func testDontLogVerboseWhenSpecified() throws {
        TestCommand().executeAndCatch(verbose: false)
        XCTAssertEqual(logger.messages, [.message("Test")])
    }
}
