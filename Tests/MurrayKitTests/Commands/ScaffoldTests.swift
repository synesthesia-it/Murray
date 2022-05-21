//
//  File.swift
//  
//
//  Created by Stefano Mondino on 20/05/22.
//

import Foundation
import XCTest
@testable import MurrayKit

class ScaffoldTests: TestCase {
    
    func testMurrayfileCreation() throws {
        let root = try Folder.emptyTestFolder()
        
        try Scaffold.murrayfile(encoding: .yml, in: root)
            .execute()
        let murrayfile = try CodableFile<Murrayfile>(in: root)
        XCTAssertEqual(murrayfile.file.name, "Murrayfile.yml")
    }
    
    func testAddNewPackageInJSONScenario() throws {
        let root = try Scenario.simpleJSON.make()
        try Scaffold
            .package(named: "testPackage", description: "", rootFolder: root)
            .execute()
        
        let murrayfile = try CodableFile<Murrayfile>(in: root)
        XCTAssertEqual(murrayfile.object.packages.last, "Murray/testPackage/testPackage.json")
        
    }
    func testAddNewPackageInYMLScenario() throws {
        let root = try Scenario.simpleYaml.make()
        try Scaffold
            .package(named: "testPackage", description: "", rootFolder: root)
            .execute()
        
        let murrayfile = try CodableFile<Murrayfile>(in: root)
        XCTAssertEqual(murrayfile.object.packages.last, "Murray/testPackage/testPackage.yml")
        
    }
    
    func testAddNewItemInYMLScenario() throws {
        let root = try Scenario.simpleYaml.make()
        try Scaffold
            .item(named: "newItem",
                  package: "simple",
                  description: "Test description",
                  rootFolder: root,
                  files: ["fileA.swift", "fileB.yml"])
            .execute()
        
        let package = try XCTUnwrap(try CodableFile<Murrayfile>(in: root)
            .packages()
            .first(where: { $0.object.name == "simple" }))
        
        let itemFolder = try XCTUnwrap(package.file.parent?.subfolder(named: "newItem"))
        let itemFile = try itemFolder.file(named: "newItem.yml")
        let item = try CodableFile(file: itemFile, type: MurrayKit.Item.self)
        XCTAssertEqual(item.object.name, "newItem")
        XCTAssertEqual(item.object.description, "Test description")
        let fileA = try itemFolder.file(named: "fileA.swift")
        let fileB = try itemFolder.file(named: "fileB.yml")
        XCTAssertEqual(try fileA.readAsString(), "")
        XCTAssertEqual(try fileB.readAsString(), "")
        
    }
    
    func testAddNewItemInJSONScenario() throws {
        let root = try Scenario.simpleJSON.make()
        try Scaffold
            .item(named: "newItem",
                  package: "simple",
                  description: "Test description",
                  rootFolder: root,
                  files: ["fileA.swift", "fileB.json"])
            .execute()
        
        let package = try XCTUnwrap(try CodableFile<Murrayfile>(in: root)
            .packages()
            .first(where: { $0.object.name == "simple" }))
        let packageFolder = try XCTUnwrap(package.file.parent)
        let itemFolder = try XCTUnwrap(packageFolder.subfolder(named: "newItem"))
        let itemFile = try itemFolder.file(named: "newItem.json")
        
        let item = try CodableFile(file: itemFile, type: MurrayKit.Item.self)
        XCTAssertEqual(item.object.name, "newItem")
        XCTAssertEqual(item.object.description, "Test description")
        let fileA = try itemFolder.file(named: "fileA.swift")
        let fileB = try itemFolder.file(named: "fileB.json")
        XCTAssertEqual(try fileA.readAsString(), "")
        XCTAssertEqual(try fileB.readAsString(), "")
        
        let itemRelativePath = itemFile.path(relativeTo: packageFolder)
        
        let procedure = Procedure(name: item.object.name,
                                  description: item.object.description,
                                  plugins: nil,
                                  itemPaths: [itemRelativePath])
        
        XCTAssertTrue(package.object.procedures.contains(procedure))
        

    }
    
    func testAddSameItemTwiceFails() throws {
        let root = try Scenario.simpleJSON.make()
        try Scaffold
            .item(named: "newItem",
                  package: "simple",
                  description: "Test description",
                  rootFolder: root,
                  files: ["fileA.swift", "fileB.json"])
            .execute()
        
        XCTAssertThrowsError(try Scaffold
            .item(named: "newItem",
                  package: "simple",
                  description: "Test description",
                  rootFolder: root,
                  files: ["fileA.swift", "fileB.json"])
                .execute()) { error in
                    XCTAssertEqual(error as? Errors, .itemAlreadyExists("newItem"))
                }
    }
    
    func testNewItemDoesNotAddProcedureWhenSpecified() throws {
        let root = try Scenario.simpleJSON.make()
        try Scaffold
            .item(named: "newItem",
                  package: "simple",
                  description: "Test description",
                  rootFolder: root,
                  createProcedure: false,
                  files: ["fileA.swift", "fileB.json"])
            .execute()
        
        let package = try XCTUnwrap(try CodableFile<Murrayfile>(in: root)
            .packages()
            .first(where: { $0.object.name == "simple" }))
        let packageFolder = try XCTUnwrap(package.file.parent)
        let itemFolder = try XCTUnwrap(packageFolder.subfolder(named: "newItem"))
        let itemFile = try itemFolder.file(named: "newItem.json")
        
        let item = try CodableFile(file: itemFile, type: MurrayKit.Item.self)
        let itemRelativePath = itemFile.path(relativeTo: packageFolder)
        let procedure = Procedure(name: item.object.name,
                                  description: item.object.description,
                                  plugins: nil,
                                  itemPaths: [itemRelativePath])
        XCTAssertTrue(!package.object.procedures.contains(procedure))
    }
    
    func testAddNewItemFailsWithMissingPackage() throws {
        let root = try Scenario.simpleJSON.make()
        XCTAssertThrowsError(try Scaffold
            .item(named: "newItem",
                  package: "notFound",
                  description: "Test description",
                  rootFolder: root,
                  files: ["fileA.swift", "fileB.json"])
            .execute()) {
                XCTAssertEqual($0 as? Errors, .invalidPackageName("notFound"))
            }
        
    }
    
    func testAddNewProcedureInInvalidPackage() throws {
        let root = try Scenario.simpleYaml.make()
    
        XCTAssertThrowsError(try Scaffold.procedure(named: "newProcedure",
                               package: "wrongValue",
                               description: "theDescription",
                               rootFolder: root,
                               itemNames: ["replacementOnly", "simpleItem"])
            .execute()) { error in
                XCTAssertEqual(error as? Errors, .invalidPackageName("wrongValue"))
            }
    }
    
    func testAddNewProcedureWithMultipleItems() throws {
        let root = try Scenario.simpleYaml.make()
        
        var package = try XCTUnwrap(try CodableFile<Murrayfile>(in: root)
            .packages()
            .first(where: { $0.object.name == "simple" }))
        
        XCTAssertNil(package.object.procedures.first { $0.name == "newProcedure" })
        
        try Scaffold.procedure(named: "newProcedure",
                               package: "simple",
                               description: "theDescription",
                               rootFolder: root,
                               itemNames: ["replacementOnly", "simpleItem"])
        .execute()
        
        try package.reload()
        let packageFolder = try XCTUnwrap(package.file.parent)
        let procedure = try XCTUnwrap(package.object.procedures.first { $0.name == "newProcedure" })
        XCTAssertEqual(procedure.description, "theDescription")
    }
    
    func testFailWhenProcedureAlreadyExists() throws {
        let root = try Scenario.simpleYaml.make()

        
        XCTAssertThrowsError(try Scaffold.procedure(named: "simpleGroup",
                               package: "simple",
                               description: "theDescription",
                               rootFolder: root,
                               itemNames: ["replacementOnly", "i do not exist"])
            .execute()) {
                XCTAssertEqual($0 as? Errors, .procedureAlreadyExists("simpleGroup"))
            }
    }
    
    func testFailWhenItemNameNotFound() throws {
        let root = try Scenario.simpleYaml.make()
        var package = try XCTUnwrap(try CodableFile<Murrayfile>(in: root)
            .packages()
            .first(where: { $0.object.name == "simple" }))
        
        XCTAssertThrowsError(try Scaffold.procedure(named: "newProcedure",
                               package: "simple",
                               description: "theDescription",
                               rootFolder: root,
                               itemNames: ["replacementOnly", "i do not exist"])
            .execute()) {
                XCTAssertEqual($0 as? Errors, .itemNotFound("i do not exist"))
            }
        try package.reload()
        XCTAssertNil(package.object.procedures.first { $0.name == "newProcedure" })
    }
}
