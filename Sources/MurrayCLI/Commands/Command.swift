//
//  Command.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import MurrayKit

protocol Command: AnyObject {
    func execute() throws
}

extension Command {
    func withVerbose(to flag: Bool) -> Self {
        Logger.logLevel = flag ? .verbose : .error
        return self
    }
}
