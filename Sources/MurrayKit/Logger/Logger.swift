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
        case .verbose: return string
        case .warning: return string.yellow
        case .network: return string.blue
        case .error: return string.red
        default: return string
        }
    }

    public var symbol: String {
        switch self {
        case .verbose: return "💬"
        case .network: return "🌐"
        case .warning: return "⚠️"
        case .error: return "⛔️"
        default: return ""
        }
    }
}

public protocol LoggerType: AnyObject {
    var logLevel: LogLevel { get set }
    func log(_ log: Log, level: LogLevel, tag: String?)
}

public enum Log: CustomStringConvertible, CustomDebugStringConvertible, Equatable {
    case error(Errors)
    case message(String)

    public var debugDescription: String {
        switch self {
        case let .error(error): return error.localizedDescription
        case let .message(string): return string
        }
    }

    public var description: String {
        switch self {
        case let .error(error): return error.localizedDescription
        case let .message(string): return string
        }
    }
}

open class ConsoleLogger: LoggerType {
    public var logLevel: LogLevel

    public init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }

    open func string(_ message: String, level: LogLevel, tag: String?) -> String? {
        if logLevel.rawValue > level.rawValue { return nil }

        let string =
            """
            \([
                [level.symbol, tag]
                    .compactMap { $0 }
                    .filter { !$0.isEmpty }
                    .joined(separator: " "),
                level
                    .colorize(string: message)
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ": ")
            )
            """
        return string
    }

    open func log(_ log: Log, level: LogLevel, tag: String?) {
        guard let string = string(log.description, level: level, tag: tag) else { return }
        print(string)
    }
}

public final class TestLogger: ConsoleLogger {
    public var messages: [Log] = []

    public var lastMessage: Log? { messages.last }

    override public func log(_ log: Log, level: LogLevel, tag _: String?) {
//        let message = log.description
//        guard let string = string(message, level: level, tag: tag) else { return }
//        print(string)
        if logLevel.rawValue > level.rawValue { return }
        messages.append(log)
        print(log.description)
    }
}

public enum Logger {
    public static var logger: LoggerType = ConsoleLogger(logLevel: .network)
    public static var logLevel: LogLevel {
        get { logger.logLevel }
        set { logger.logLevel = newValue }
    }

    public static func log(_ message: String, level: LogLevel = .error, tag: String? = nil) {
        log(.message(message), level: level, tag: tag)
    }

    public static func log(_ log: Log, level: LogLevel = .error, tag: String? = nil) {
        logger.log(log, level: level, tag: tag)
    }
}
