//
//  XCodePlugin.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 21/01/2020.
//

import Foundation
import Files
import Gloss
import ShellOut
import XcodeProj
import PathKit

open class XCodePlugin: Plugin {
    override open var name: String { return "xcode" }
    private struct PluginData: JSONDecodable {
        let targets: [String]
        init?(json: JSON) {
            guard let targets:[String] = "targets" <~~ json else { return nil }
            self.targets = targets
        }
    }
    
    
    open override func execute(phase: PluginPhase, from folder: Folder) throws {
        switch phase {
        case .afterItemReplace(let item, let context): try process(item: item.object, file: item.file, projectFolder: folder, context: context)
        default: break
        }
    }
    
    func process(item: BoneItem, file: File, projectFolder: Folder, context: BoneContext) throws {
        Logger.log("Attempting to process item '\(item.name)', file '\(file)' with context: \(context)", level: .verbose)
        guard let data: PluginData = self.pluginData(for: item) else { return }
        guard let projectFolder = projectFolder.subfolders
            .filter ({ $0.name.contains(".xcodeproj") })
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
        Logger.log("Matching targets: \(targets.map{ $0.name }.joined(separator: ", "))", level: .verbose)
        files.forEach { file in
            let folders = file.parent?.path(relativeTo: projectFolder.parent!).components(separatedBy: "/").filter { $0.isEmpty == false } ?? []
            guard let mainGroup = pbx.mainGroup else { return }
            let group = folders.reduce(mainGroup) { group, folder -> PBXGroup? in

                return group?.group(named: folder) ?? (try? group?.addGroup(named: folder).first)
            }

            if let addedFile = try? group?.addFile(at: Path(file.path), sourceRoot: Path(projectFolder.path)) {
                targets.forEach { target in
                    Logger.log("Adding file \(addedFile.name ?? "n/a") to target \(target.name)", level: .verbose)
                    do {
                    _ = try target.sourcesBuildPhase()?.add(file: addedFile)
                    } catch let error {
                        Logger.log("Error adding file \(addedFile.name ?? "") to target \(target.name):")
                        Logger.log(error.localizedDescription)
                    }
                }
            }
        }
        do {
            try project?.write(path: Path(projectFolder.path), override: true)
        } catch let error {
            Logger.log("Error saving project")
            Logger.log(error.localizedDescription)
        }
        }
}
