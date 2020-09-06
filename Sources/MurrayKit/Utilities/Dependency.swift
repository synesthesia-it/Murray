//
//  Dependency.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 03/01/2019.
//

import Foundation
import ShellOut

/// Mainly used for dependency injection in tests
public protocol Dependency {
    func cloneSkeleton(from repository: Repository) throws
    func cloneBones(from repository: Repository) throws
}

private class DefaultDependency: Dependency {
    private func clone(from repository: Repository) throws {
        let command = "git clone --single-branch --branch \(repository.version) \(repository.repo)"
        try shellOut(to: command)
    }

    func cloneSkeleton(from repository: Repository) throws {
        try clone(from: repository)
    }

    func cloneBones(from repository: Repository) throws {
        try clone(from: repository)
    }
}

public struct DependencyManager {
    static var shared: Dependency = DefaultDependency()
    static func reset() {
        shared = DefaultDependency()
    }
}
