import MurrayCLI
import MurrayKit
import Files
class CLILogger: ConsoleLogger {
    open override func string(_ message: String, level: LogLevel, tag: String?) -> String? {
        if (self.logLevel.rawValue > level.rawValue) { return nil }

        let string =
        """
        \([
            [tag]
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
    
}

Logger.logger = CLILogger(logLevel: .normal)
//Menu.menu.run()

try SkeletonPipeline(folder: Folder.current, projectName: "Mondini")
    .execute(projectPath: "~/Desktop/Pipeline", with: [:])

//do {
//    tool.run()
//} catch {
//    print("Whoops! An error occurred: \(error)")
//}
