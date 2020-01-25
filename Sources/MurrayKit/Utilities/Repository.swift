//
//  PathReference.swift
//  MurrayKit
//  Inspired by Mint, from here: https://github.com/yonaskolb/Mint/blob/master/Sources/MintKit/PackageReference.swift
//
//  Created by Stefano Mondino on 07/01/2019.
//

import Foundation

public class Repository: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(repo.hashValue)
    }
    public var repo: String
    public var version: String
    public var package:String
    public init(repo: String, version: String = "", package: String? = nil) {
        self.repo = repo
        self.version = version
        self.package = package ?? [repo,version]
            .map { $0.trimmingCharacters(in: .whitespaces)}
            .filter { $0.count > 0 }
            .joined(separator: "@")
    }
    
    public convenience init(package: String) {
        
        let packageParts = package.components(separatedBy: "@")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        let repo: String
        let version: String
        if packageParts.count == 3 {
            repo = [packageParts[0], packageParts[1]].joined(separator: "@")
            version = packageParts[2]
        } else if packageParts.count == 2 {
            if packageParts[1].contains(":") {
                repo = [packageParts[0], packageParts[1]].joined(separator: "@")
                version = ""
            } else {
                repo = packageParts[0]
                version = packageParts[1]
            }
        } else {
            repo = package
            version = "master"
        }
        self.init(repo: repo, version: version, package: package)
    }
    
    public var namedVersion: String {
        return "\(name) \(version)"
    }
    
    public var name: String {
        return repo.components(separatedBy: "/").last!.components(separatedBy: ".").first!
    }
    
    
}

extension Repository: Equatable {
    public static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.repo == rhs.repo && lhs.version == rhs.version
    }
}
