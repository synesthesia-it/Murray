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
            do {
                return try folder.file(named: filename)
            } catch {
                throw MurrayKit.CustomError.fileNotFound(path: filename, folder: folder)
            }
        }
        
        init(path: String, in folder: Folder) throws {
            
            let components = path.components(separatedBy: "/").filter { !$0.isEmpty }
            let subfolders = components.dropLast()
            
            guard let filename = components.last else {
                //filename not found. exit.
                throw MurrayKit.CustomError.invalidPath(path: path)
            }
            
            self.filename = filename
            try self.folder = subfolders.reduce(folder) {
                do {
                    return try $0.createSubfolderIfNeeded(withName: $1)
                } catch {
                    throw CustomError.unableToCreateFolder(path: $1, folder: $0)
                }
            }
        }
    }
    
    func createFileWithIntermediateFolders(at path: String, contents: Data, overwriteContents: Bool = false) throws -> File {
        
            
        let subElement = try SubElement(path: path, in: self)
        
        if subElement.folder.containsFile(named: subElement.filename) && overwriteContents == false {
            //File already exist. exit
            throw MurrayKit.CustomError.fileNotFound(path: subElement.filename, folder: subElement.folder)
        }
        do {
            return try subElement.folder.createFile(named: subElement.filename, contents: contents)
        } catch {
            throw MurrayKit.CustomError.unableToCreateFile(path: subElement.filename, folder: subElement.folder, contents: contents)
        }
    }
    
    func decodable<T: JSONDecodable>(_ type: T.Type, at path: String) throws -> T? {
        let element = try SubElement(path: path, in: self)
        let file = try element.file()
        
        guard let decoded: T = try file.decodable(T.self) else {
            throw MurrayKit.CustomError.undecodable(file: file, type: T.self)
        }
        return decoded
    }
    
}

public extension File {
    func decodable<T: JSONDecodable>(_ type: T.Type) throws -> T? {
        let data = try self.read()
        return T.init(data: data)
    }
}
