//
//  Command.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation

public protocol Command: AnyObject {
    func execute() throws
}

public extension Command {
    func withVerbose(to flag: Bool) -> Self {
        Logger.logLevel = flag ? .verbose : .error
        return self
    }
}
