//
//  File.swift
//  
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation

public protocol Command {
    func execute() throws
    func executeAndCatch(verbose: Bool)
}

public extension Command {
    
    func executeAndCatch(verbose: Bool) {
        do {
            if verbose {
                Logger.logLevel = .verbose
            }
            try execute()
        } catch let error {
            switch error {
            case let error as Errors: Logger.log(.error(error))
//            case let error as Files.LocationError:
//                Logger.log("Some error occured with file at:\(error.path)")
            default: Logger.log(error.localizedDescription)
            }
        }
    }
}
