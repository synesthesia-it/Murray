//
//  Bonefile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files

class BoneFile {
    struct Part {
        let url: URL
        let branch: String
        init(string: String) throws {
            let parts = string.components(separatedBy: "@")
            guard let urlString = parts.first,
            let url = URL(string: urlString)
            else {
                throw Bone.Error.invalidBonefile
            }
            self.url = url
            if parts.count > 1 {
                self.branch = parts[1]
            } else {
                branch = "master"
            }

        }
    }

    let contents: String
    var parts: [Part] = []
    init(fileContents: String) throws {

        self.contents = fileContents
        parts = try partsFromBonefile()
    }
    private func partsFromBonefile() throws -> [Part] {
//        let fs = FileSystem()
//        guard let boneFile = try? fs.currentFolder.file(named: "Bonefile") else {
//            throw Template.Error.missingBonefile
//        }
//        let contents = try boneFile.readAsString()
        let set = Set(
            self.contents.components(separatedBy: "\n")
                .map {$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
                .filter { $0.count > 0}
                .compactMap { string -> String? in
                    let strings = string.components(separatedBy: " ")
                    guard let command = strings.first,
                        strings.count == 2,
                        command == "bone"
                        else { return nil }

                    return strings.last?.replacingOccurrences(of: "\"", with: "")

                }
                .compactMap { $0 }
//                .map { try Part(string: $0) }
            )
        return try set.map { try Part(string: $0)}

    }
}
