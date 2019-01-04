//
//  Dependency.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 03/01/2019.
//

import Foundation
import ShellOut

///Mainly used for dependency injection in tests
public protocol Dependency {
    func cloneProject(from: URL) throws
}

private class DefaultDependency: Dependency {
    func cloneProject(from git: URL) throws {
        try shellOut(to:.gitClone(url: git))
    }
}
public struct DependencyManager {
    static var shared: Dependency = DefaultDependency()
    static func reset() {
        shared = DefaultDependency()
    }
}
