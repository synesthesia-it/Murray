//
//  File.swift
//  
//
//  Created by Stefano Mondino on 23/05/22.
//

import Foundation

struct ShellPlugin: Plugin {
    var name: String { "shell" }
        
    struct PluginData: Codable {
        let before: [String]?
        let after: [String]?
    }

    func execute<Element: PluginDataContainer>(_ execution: PluginExecution<Element>) throws {
        let keyPath: KeyPath<PluginData, [String]?>
        switch execution.phase {
        case .before: keyPath = \.before
        case .after: keyPath = \.after
        }
       
        guard let data = try self.data(for: execution.element),
        let commands = data[keyPath: keyPath] else {
            return
        }
        
        let context = execution.context()
        try commands.map {
            try $0.resolve(with: context)
        }.forEach {
            Logger.log("Executing command: \($0)", level: .verbose)
            try Process().launchBash(with: $0)
        }
    }
    
}

private extension Process {
    @discardableResult func launchBash(with command: String,
                                       outputHandle: FileHandle? = nil,
                                       errorHandle: FileHandle? = nil) throws -> String {
        launchPath = "/bin/bash"
        arguments = ["-c", command]

        // Because FileHandle's readabilityHandler might be called from a
        // different queue from the calling queue, avoid a data race by
        // protecting reads and writes to outputData and errorData on
        // a single dispatch queue.
        let outputQueue = DispatchQueue(label: "bash-output-queue")

        var outputData = Data()
        var errorData = Data()

        let outputPipe = Pipe()
        standardOutput = outputPipe

        let errorPipe = Pipe()
        standardError = errorPipe

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                outputData.append(data)
                outputHandle?.write(data)
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            outputQueue.async {
                errorData.append(data)
                errorHandle?.write(data)
            }
        }
        #endif

        launch()

        #if os(Linux)
        outputQueue.sync {
            outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        }
        #endif

        waitUntilExit()

        if let handle = outputHandle, !handle.isStandard {
            handle.closeFile()
        }

        if let handle = errorHandle, !handle.isStandard {
            handle.closeFile()
        }

        #if !os(Linux)
        outputPipe.fileHandleForReading.readabilityHandler = nil
        errorPipe.fileHandleForReading.readabilityHandler = nil
        #endif

        // Block until all writes have occurred to outputData and errorData,
        // and then read the data back out.
        return try outputQueue.sync {
            if terminationStatus != 0 {
                throw ShellOutError(
                    terminationStatus: terminationStatus,
                    errorData: errorData,
                    outputData: outputData
                )
            }

            return outputData.shellOutput()
        }
    }
}

private extension FileHandle {
    var isStandard: Bool {
        return self === FileHandle.standardOutput ||
            self === FileHandle.standardError ||
            self === FileHandle.standardInput
    }
}

private extension Data {
    func shellOutput() -> String {
        guard let output = String(data: self, encoding: .utf8) else {
            return ""
        }

        guard !output.hasSuffix("\n") else {
            let endIndex = output.index(before: output.endIndex)
            return String(output[..<endIndex])
        }

        return output

    }
}
/// Error type thrown by the `shellOut()` function, in case the given command failed
struct ShellOutError: Swift.Error {
    /// The termination status of the command that was run
     let terminationStatus: Int32
    /// The error message as a UTF8 string, as returned through `STDERR`
     var message: String { return errorData.shellOutput() }
    /// The raw error buffer data, as returned through `STDERR`
     let errorData: Data
    /// The raw output buffer data, as retuned through `STDOUT`
     let outputData: Data
    /// The output of the command as a UTF8 string, as returned through `STDOUT`
     var output: String { return outputData.shellOutput() }
}
