//
//  File.swift
//
//
//  Created by Stefano Mondino on 20/05/22.
//

import Foundation
import MurrayKit
import XCTest

class TestCase: XCTestCase {
    var logger = TestLogger(logLevel: .normal)
    let formatter = DateFormatter()
    var year: String {
        string(from: .init(), format: "yyyy")
    }

    func string(from _: Date, format: String) -> String {
        formatter.dateFormat = format
        return formatter.string(from: .init())
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        logger = TestLogger(logLevel: .normal)
        Logger.logger = logger
    }
}
