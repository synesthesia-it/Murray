//
//  Command.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Files
import Foundation

public protocol Command: AnyObject {
    var folder: Folder { get set }
    func execute() throws
}

public extension Command {
    func withVerbose(to flag: Bool) -> Self {
        Logger.logLevel = flag ? .verbose : .error
        return self
    }

    func fromFolder(_ folder: Folder) -> Self {
        self.folder = folder
        return self
    }
}
