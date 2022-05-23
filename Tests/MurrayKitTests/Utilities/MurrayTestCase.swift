//
//  File.swift
//  
//
//  Created by Stefano Mondino on 20/05/22.
//

import Foundation
import XCTest
import MurrayKit

class TestCase: XCTestCase {
    var logger = TestLogger(logLevel: .normal)
   
    override func setUpWithError() throws {
        try super.setUpWithError()
        logger = TestLogger(logLevel: .normal)
        Logger.logger = logger
        
    }
}
