//
//  File.swift
//
//
//  Created by Stefano Mondino on 30/01/22.
//

import Files
import Foundation
import Yams

/// A codable object with a local file system (File) representation
public struct CodableFile<Object: Codable> {
    public let file: File
    public let object: Object

    public init(file: File, object: Object) {
        self.file = file
        self.object = object
    }

    public init(file: File, type _: Object.Type = Object.self) throws {
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
}
