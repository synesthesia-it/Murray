//
//  SpecManager.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 10/01/2020.
//

import Foundation
import Files
import Gloss


public extension Folder {
    private struct SubElement {
        let folder: Folder
        let filename: String
        
        func file() throws -> File {
            return try folder.file(named: filename)
        }
        
        init(path: String, in folder: Folder) throws {
            
            let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
            let subfolders = components.dropLast()
            
            guard let filename = components.last else {
                //filename not found. exit.
                throw MurrayKit.Error.generic
            }
            
            self.filename = filename
            try self.folder = subfolders.reduce(folder) {
                 try $0.createSubfolderIfNeeded(withName: $1)
            }
        }
    }
    
    func createFileWithIntermediateFolders(at path: String, contents: Data) throws -> File {
        
            
        let subElement = try SubElement(path: path, in: self)
        
        if subElement.folder.containsFile(named: subElement.filename) {
            //File already exist. exit
            throw MurrayKit.Error.generic
        }
        return try subElement.folder.createFile(named: subElement.filename, contents: contents)
    }
    
    func decodable<T: JSONDecodable>(_ type: T.Type, at path: String) throws -> T? {
        let element = try SubElement(path: path, in: self)
        let file = try element.file()
        return try file.decodable(T.self)
    }
}

public extension File {
    func decodable<T: JSONDecodable>(_ type: T.Type) throws -> T? {
        let data = try self.read()
        return T.init(data: data)
    }
}
