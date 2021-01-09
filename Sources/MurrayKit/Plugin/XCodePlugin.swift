//
//  XCodePlugin.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 21/01/2020.
//

import Files
import Foundation
import Gloss
import PathKit
import ShellOut
import XcodeProj

open class XCodePlugin: Plugin {
    override open var name: String { return "xcode" }
    private struct PluginData: JSONDecodable {
        let targets: [String]

        init(targets: [String]) {
            self.targets = targets
        }

        init?(json: JSON) {
            guard let targets: [String] = "targets" <~~ json else { return nil }
            self.targets = targets
        }

        func adding(defaultData: JSON) -> PluginData {
            guard
                let newData = PluginData(json: defaultData)
            else {
                return self
            }
            return PluginData(targets: [newData.targets, targets].compactMap { $0 }.flatMap { $0 })
        }
    }

    override open func execute(phase: PluginPhase, from folder: Folder, defaultData: JSON?) throws {
        switch phase {
        case let .afterItemReplace(item, context): try process(item: item.object, file: item.file, projectFolder: folder, context: context, defaultData: defaultData)
        default: break
        }
    }

    func process(item: BoneItem, file: File, projectFolder: Folder, context: BoneContext, defaultData: JSON?) throws {
        Logger.log("Attempting to process item '\(item.name)', file '\(file)' with context: \(context)", level: .verbose)
        guard let data: PluginData = pluginData(for: item, type: PluginData.self)?
            .adding(defaultData: defaultData ?? [:])
        else { return }
        guard let projectFolder = projectFolder.subfolders
            .filter({ $0.name.contains(".xcodeproj") })
            .first else { return }
        let targetNames = Set(try data.targets.map { try $0.resolved(with: context) })
        Logger.log("Required targets: \(targetNames.joined(separator: ", "))", level: .verbose)
        guard targetNames.isEmpty == false else { return }

        let files = (try? item.paths
            .compactMap { try? $0.to.resolved(with: context) }
            .compactMap { (try projectFolder.parent?.file(at: $0)) }) ?? []

        let project = try? XcodeProj(pathString: projectFolder.path)
        guard let pbx = project?.pbxproj.projects.first else { return }
        let targets = pbx.targets.filter { targetNames.contains($0.name) }
        Logger.log("Matching targets: \(targets.map { $0.name }.joined(separator: ", "))", level: .verbose)
        files.forEach { file in
            let folders = file.parent?.path(relativeTo: projectFolder.parent ?? projectFolder).components(separatedBy: "/").filter { $0.isEmpty == false } ?? []
            guard let mainGroup = pbx.mainGroup else { return }
            let group = folders.reduce(mainGroup) { group, folder -> PBXGroup? in

                group?.group(named: folder)
                    ?? group?.children.filter { $0.path == folder }.compactMap { $0 as? PBXGroup }.first
                    ?? (try? group?.addGroup(named: folder).first)
            }

            if let addedFile = try? group?.addFile(at: Path(file.path), sourceRoot: Path(projectFolder.parent?.path ?? projectFolder.path)) {
                targets.forEach { target in
                    Logger.log("Adding file \(addedFile.name ?? "n/a") to target \(target.name)", level: .verbose)
                    do {
//                        if Path(file.path).extension == "xib" {
                        addedFile.explicitFileType = nil
//                        }
                        _ = try self.getBuildPhase(for: Path(file.path), target: target)?.add(file: addedFile)

                    } catch {
                        Logger.log("Error adding file \(addedFile.name ?? "") to target \(target.name):")
                        Logger.log(error.localizedDescription)
                    }
                }
            }
        }
        do {
            try project?.write(path: Path(projectFolder.path), override: true)
        } catch {
            Logger.log("Error saving project")
            Logger.log(error.localizedDescription)
        }
    }

    // swiftlint:disable function_body_length
    /// adapted from here https://github.com/yonaskolb/XcodeGen/blob/master/Sources/XcodeGenKit/SourceGenerator.swift
    private func getBuildPhase(for path: Path, target: PBXTarget) throws -> PBXBuildPhase? {
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
