//
//  File.swift
//
//
//  Created by Stefano Mondino on 31/05/22.
//

import Foundation
import PathKit
import XcodeProj

struct XcodePlugin: Plugin {
//    fileprivate typealias Path = XcodeProj.Path
    var name: String { "xcode" }
    struct PluginData: Codable {
        let targets: [String]
    }

    func execute(_ execution: PluginExecution<Item.Path>) throws {
        if execution.phase == .before { return }
        guard let projectFolder = execution.root.subfolders
            .filter({ $0.name.contains(".xcodeproj") })
            .first else { return }
        let context = execution.context()
        guard let data = try data(for: execution.element) else {
            return
        }
        let targetNames = try Set(data.targets.map { try $0.resolve(with: context) })
        Logger.log("Required targets: \(targetNames.joined(separator: ", "))", level: .verbose)
        guard targetNames.isEmpty == false else { return }

        let files = (try? [execution.element]
            .compactMap { try? $0.to.resolve(with: context) }
            .compactMap { try execution.root.file(at: $0) }) ?? []

        let project = try? XcodeProj(pathString: projectFolder.path)
        guard let pbx = project?.pbxproj.projects.first else { return }
        let targets = pbx.targets.filter { targetNames.contains($0.name) }
        Logger.log("Matching targets: \(targets.map { $0.name }.joined(separator: ", "))", level: .verbose)

        files.forEach { file in
            let relativeFolder: Folder = projectFolder.parent ?? projectFolder

            let folders = file.parent?.path(relativeTo: relativeFolder).components(separatedBy: "/").filter { $0.isEmpty == false } ?? []
            guard let mainGroup = pbx.mainGroup else { return }
            let group = folders
                .reduce(mainGroup) { group, folder -> PBXGroup? in
                    group?.group(named: folder) ??
                        group?.children
                        .filter { $0.path == folder }
                        .compactMap { $0 as? PBXGroup }
                        .first ??
                        (try? group?.addGroup(named: folder).first)
                }

            if let addedFile = try? group?.addFile(at: .init(file.path), sourceRoot: .init(projectFolder.parent?.path ?? projectFolder.path)) {
                targets.forEach { target in
                    Logger.log("Adding file \(addedFile.name ?? "n/a") to target \(target.name)", level: .verbose)
                    do {
//                        if Path(file.path).extension == "xib" {
                        addedFile.explicitFileType = nil
//                        }
                        _ = try getBuildPhase(for: .init(file.path),
                                              target: target)?
                            .add(file: addedFile)

                    } catch {
                        Logger.log("Error adding file \(addedFile.name ?? "") to target \(target.name):")
                        Logger.log(error.localizedDescription)
                    }
                }
            }
        }
        do {
            try project?.write(path: .init(projectFolder.path), override: true)
        } catch {
            Logger.log("Error saving project")
            Logger.log(error.localizedDescription)
        }
    }

    func execute(_: PluginExecution<Murrayfile>) throws {}

    func execute(_: PluginExecution<Procedure>) throws {}

    func execute(_: PluginExecution<Item>) throws {}

    func execute(_: PluginExecution<Item.Replacement>) throws {}

    // adapted from here https://github.com/yonaskolb/XcodeGen/blob/master/Sources/XcodeGenKit/SourceGenerator.swift
    private func getBuildPhase(for path: PathKit.Path,
                               target: PBXTarget) throws -> PBXBuildPhase? {
        if path.lastComponent == "Info.plist" {
            return nil
        }
        if let fileExtension = path.extension {
            switch fileExtension {
            case "swift",
                 "m",
                 "mm",
                 "cpp",
                 "c",
                 "cc",
                 "S",
                 "xcdatamodeld",
                 "intentdefinition",
                 "metal",
                 "mlmodel",
                 "rcproject":
                return try target.sourcesBuildPhase()
            case "h",
                 "hh",
                 "hpp",
                 "ipp",
                 "tpp",
                 "hxx",
                 "def":
                return nil
            case "modulemap":
                return nil
            case "framework":
                return try target.frameworksBuildPhase()
            case "xpc":
                return nil
            case "xcconfig",
                 "entitlements",
                 "gpx",
                 "lproj",
                 "xcfilelist",
                 "apns",
                 "pch":
                return nil
            default:
                return try target.resourcesBuildPhase()
            }
        }
        return nil
    }
}
