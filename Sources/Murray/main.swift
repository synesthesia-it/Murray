import MurrayKit
// class CLILogger: ConsoleLogger {
//    override open func string(_ message: String, level: LogLevel, tag: String?) -> String? {
//        if logLevel.rawValue > level.rawValue { return nil }
//
//        let string =
//            """
//            \([
//                [tag]
//                    .compactMap { $0 }
//                    .filter { !$0.isEmpty }
//                    .joined(separator: " "),
//                level
//                    .colorize(string: message),
//            ]
//            .compactMap { $0 }
//            .filter { !$0.isEmpty }
//            .joined(separator: ": ")
//            )
//            """
//        return string
//    }
// }

// Logger.logger = CLILogger(logLevel: .normal)
commands().run()

// try SkeletonPipeline(folder: Folder.current, projectName: "Mondini")
//    .execute(projectPath: "~/Desktop/Pipeline", with: [:])
//
// do {
//    tool.run()
// } catch {
//    print("Whoops! An error occurred: \(error)")
// }
