//
//  Logger.swift
//  App
//
//  Created by Stefano Mondino on 17/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import Rainbow

public enum LogLevel: Int {
    case verbose = 1
    case warning = 10
    case network = 20
    case error = 100
    case normal = 200
    case none = 1000

    public func colorize(string: String) -> String {
        switch self {
        case .verbose : return string
        case .warning : return string.yellow
        case .network : return string.blue
        case .error: return string.red
        default : return string
        }
    }
    public var symbol: String {
        switch self {
        case .verbose: return "💬"
        case .network: return "🌐"
        case .warning: return "⚠️"
        case .error : return "⛔️"
        default : return ""
        }
    }
}


public protocol LoggerType: AnyObject {
    var logLevel: LogLevel { get set }
    func log(_ message: String, level: LogLevel, tag: String?)
}

open class ConsoleLogger: LoggerType {

    public var logLevel: LogLevel
    
    public init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    open func string(_ message: String, level: LogLevel, tag: String?) -> String? {
        if (self.logLevel.rawValue > level.rawValue) { return nil }

        let string =
        """
        \([
            [level.symbol, tag]
                .compactMap { $0 }
                .filter { $0.count > 0 }
                .joined(separator: " "),
            level
                .colorize(string: message)
        ]
        .compactMap { $0 }
        .filter { $0.count > 0 }
        .joined(separator: ": ")
        )
        """
        return string
    }
    
    open func log(_ message: String, level: LogLevel, tag: String?) {
        guard let string = self.string(message, level: level, tag: tag) else { return }
        print (string)
    }
}

public final class TestLogger: ConsoleLogger {
    
    public var lastMessage: String?
    
    override public func log(_ message: String, level: LogLevel, tag: String?) {
        guard let string = self.string(message, level: level, tag: tag) else { return }
        print (string)
        self.lastMessage = message
    }
}

public final class Logger {
    public static var logger: LoggerType = ConsoleLogger(logLevel: .network)
    public static var logLevel: LogLevel {
        get { logger.logLevel }
        set { logger.logLevel = newValue }
    }
    public static func log(_ message: String, level: LogLevel = .error, tag: String? = nil) {
        logger.log(message, level: level, tag: tag)
    }
}
