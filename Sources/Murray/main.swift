import Commander
import Foundation
import MurrayKit

commands().run()

func withVerbose(_ verbose: Bool, callback: () throws -> Void) rethrows {
    if verbose {
        Logger.logLevel = .verbose
    }
    try callback()
}
