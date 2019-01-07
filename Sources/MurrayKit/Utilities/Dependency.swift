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
    func cloneSkeleton(from: URL) throws
    func cloneBones(from: URL, branch: String) throws
}

private class DefaultDependency: Dependency {
    func cloneSkeleton(from git: URL) throws {
        try shellOut(to: .gitClone(url: git))
    }
    func cloneBones(from git: URL, branch: String) throws {

        let command = "git clone --single-branch --branch \(branch) \(git.absoluteString)"
        try shellOut(to: command)
//        try shellOut(to: .gitClone(url: git))
    }
}
public struct DependencyManager {
    static var shared: Dependency = DefaultDependency()
    static func reset() {
        shared = DefaultDependency()
    }
}
