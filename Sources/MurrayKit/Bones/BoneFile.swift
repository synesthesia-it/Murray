//
//  Bonefile.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation
import Files

class BoneFile {

    let contents: String
    var repositories: [Repository] = []
    init(fileContents: String) {

        self.contents = fileContents
        repositories = parseRepositories()
    }
    private func parseRepositories() -> [Repository] {
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
        return set.map { Repository(package: $0)}

    }
}
