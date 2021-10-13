//
//  SpecManager.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 10/01/2020.
//

import Files
import Foundation
import Gloss
import Yams

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
                // filename not found. exit.
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

        if subElement.folder.containsFile(named: subElement.filename), overwriteContents == false {
            // File already exist. exit
            throw MurrayKit.CustomError.fileNotFound(path: subElement.filename, folder: subElement.folder)
        }
        do {
            return try subElement.folder.createFile(named: subElement.filename, contents: contents)
        } catch {
            throw MurrayKit.CustomError.unableToCreateFile(path: subElement.filename, folder: subElement.folder, contents: contents)
        }
    }

    func decodable<T: JSONDecodable>(_: T.Type, at path: String) throws -> T? {
        let element = try SubElement(path: path, in: self)
        let file = try element.file()

        guard let decoded: T = try file.decodable(T.self) else {
            throw MurrayKit.CustomError.undecodable(file: file, type: T.self)
        }
        return decoded
    }
}

public extension File {
    func decodable<T: JSONDecodable>(_: T.Type) throws -> T? {
        let data = try read()
        return T(data: data, serializer: GlossJSONSerializer()) ?? T(data: data, serializer: YAMLSerializer())
    }
}

struct YAMLSerializer: JSONSerializer {
    init() {}
    func json(from data: Data, options _: JSONSerialization.ReadingOptions) -> JSON? {
        guard let string = String(data: data, encoding: .utf8),
              let json = try? Yams.load(yaml: string) as? JSON else { return nil }
        return json
    }

    func jsonArray(from data: Data, options _: JSONSerialization.ReadingOptions) -> [JSON]? {
        guard let string = String(data: data, encoding: .utf8),
              let json = try? Yams.load(yaml: string) as? [JSON] else { return nil }
        return json
    }

    func data(from json: JSON, options _: JSONSerialization.WritingOptions?) -> Data? {
        (try? Yams.dump(object: json))?.data(using: .utf8)
    }
}
