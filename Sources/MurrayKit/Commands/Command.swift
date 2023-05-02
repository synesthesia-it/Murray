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

public protocol CommandWithContext: Command {
    var mainPlaceholder: String { get }
    var params: [String] { get }
}

public extension CommandWithContext {
    func context(mainPlaceholderKey: String) -> JSON {
        return params.reduce(into: [mainPlaceholderKey: mainPlaceholder]) { context, pair in
            let elements = pair.components(separatedBy: ":")
            guard elements.count == 2 else { return }
            context[elements[0]] = elements[1]
        }
    }
}

public extension Command {
    func executeAndCatch(verbose: Bool) {
        do {
            if verbose {
                Logger.logLevel = .verbose
            }
            try execute()
        } catch {
            switch error {
            case let error as Errors: Logger.log(.error(error))
//            case let error as Files.LocationError:
//                Logger.log("Some error occured with file at:\(error.path)")
            default: Logger.log(error.localizedDescription)
            }
        }
    }
}
