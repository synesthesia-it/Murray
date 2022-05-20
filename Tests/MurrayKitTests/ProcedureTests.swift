//
//  File.swift
//  
//
//  Created by Stefano Mondino on 11/05/22.
//


import Foundation
import Yams
@testable import MurrayKit
import XCTest

class ProcedureTests: TestCase {
    
    func testJSONValidProcedure() throws {
        let json = """
        {
          "name": "simpleGroup",
          "description": "custom description",
          "items": [
            "SimpleItem/SimpleItem.json"
          ]
        }
        """
        let procedure = try JSONDecoder().decode(json, of: Procedure.self)
        XCTAssertEqual(procedure.name, "simpleGroup")
        XCTAssertEqual(procedure.description, "custom description")
        XCTAssertEqual(procedure.itemPaths.first, "SimpleItem/SimpleItem.json")
    }
    
    func testJSONProcedureWithEmptyDescription() throws {
        let json = """
        {
          "name": "simpleGroup",
          "items": [
            "SimpleItem/SimpleItem.json"
          ]
        }
        """
        let procedure = try JSONDecoder().decode(json, of: Procedure.self)
        XCTAssertEqual(procedure.name, "simpleGroup")
        XCTAssertEqual(procedure.description, "simpleGroup")
        XCTAssertEqual(procedure.itemPaths.first, "SimpleItem/SimpleItem.json")
    }
}
