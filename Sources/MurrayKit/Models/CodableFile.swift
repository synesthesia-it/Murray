//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//


import Foundation
import Yams

/// A codable object with a local file system (File) representation
public struct CodableFile<Object: Codable & Hashable>: Hashable {
    
    public enum Encoding: String {
        case json
        case yml
        
        static var allValidExtensions: [String] {
            ["json", "yml", "yaml"]
        }
        
        fileprivate var encoder: Encoder {
            switch self {
            case .json: return JSONEncoder()
            case .yml: return YAMLEncoder()
            }
        }
        public init?(rawValue: String?) {
            guard let rawValue = rawValue else {
                return nil
            }
            switch rawValue {
            case "json": self = .json
            case "yml", "yaml": self = .yml
            default: return nil
            }
        }
    }
    
    public let file: File
    public private(set) var object: Object

    public init(file: File, object: Object) {
        self.file = file
        self.object = object
    }
    
    public mutating func reload() throws {
        self.object = try Self.init(file: file).object
    }
    
    public init(file: File,
                type _: Object.Type = Object.self) throws {
//        self.file = file
        let data = try file.read()
        if let ext = file.extension,
           let decoder: Decoder = Self.decoder(from: ext) {
            self.init(file: file, object: try decoder.decode(data))

        } else {
            let decoders: [Decoder] = [JSONDecoder(), YAMLDecoder()]
            guard let object = decoders
                .lazy
                .compactMap({ try? $0.decode(data, of: Object.self) })
                .first
            else {
                throw Errors.unparsableFile(file.path)
            }
            self.init(file: file, object: object)
        }
    }

    fileprivate static func decoder(from ext: String) -> Decoder? {
        switch ext.lowercased() {
        case "json":
            return JSONDecoder()
        case "yml", "yaml":
            return YAMLDecoder(encoding: .utf8)
        default:
            return nil
        }
    }
    
    fileprivate static func encoder(from ext: String) -> Encoder? {
        switch ext.lowercased() {
        case "json":
            return JSONEncoder()
        case "yml", "yaml":
            return YAMLEncoder()
        default:
            return nil
        }
    }
    
    @discardableResult
    public static func create(_ object: Object,
                       encoding: Encoding = .yml,
                       named name: String,
                       in folder: Folder) throws -> CodableFile<Object> {
        
        let data = try encoding.encoder.encode(object)
        
        let file = try folder.createFileIfNeeded(at: name, contents: data)
        return .init(file: file, object: object)
    }
    
    private mutating func update(_ object: Object) throws {
        let data: Data
        if let ext = file.extension,
           let encoder: Encoder = Self.encoder(from: ext) {
            data = try encoder.encode(object)
        } else {
            let encoders: [Encoder] = [JSONEncoder(), YAMLEncoder()]
            guard let encodedData = encoders
                .lazy
                .compactMap({ try? $0.encode(object) })
                .first
            else {
                throw Errors.unwriteableFile(file.path)
            }
            data = encodedData
        }
        guard let string = String(data: data, encoding: .utf8) else {
            throw Errors.unwriteableFile(file.path)
        }
        try self.file.write(string,encoding: .utf8)
        self.object = object
    }
    
    public mutating func update(_ closure: @escaping (inout Object) throws -> Void) throws {
        try closure(&object)
        try self.update(self.object)
    }
}
