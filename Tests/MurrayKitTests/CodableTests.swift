//
//  File.swift
//
//
//  Created by Stefano Mondino on 01/05/23.
//

import Foundation
@testable import MurrayKit
import XCTest
import Yams

class CodableTests: TestCase {
    func testYAMLFileProducesProperError() throws {
        let scenario = Scenario.wrongMurrayfile
        let root = try scenario.make()
        XCTAssertThrowsError(try CodableFile<Murrayfile>(in: root).object) { error in
            switch error as? Errors ?? .unknown {
            case .unparsableFile: return
            default: XCTFail("\(error) is not of expected type")
            }
        }
    }
}
