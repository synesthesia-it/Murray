//
//  Bone+Pipeline.swift
//  MurrayKit
//
//  Created by Stefano Mondino on 05/01/2019.
//

import Foundation
import Files
import ShellOut

extension Bone {
    static func newTemplate(bone boneName: String, name: String, listName: String = "", targetName: String = "") throws {
        let fs = FileSystem()
    
        guard var bonesFolder = try? fs.currentFolder.subfolder(named: murrayTemplatesFolderName) else {
            throw Error.missingSetup
        }
        let scriptPath = "\(murrayTemplatesFolderName)/script.rb"
        FileManager.default.createFile(atPath: scriptPath, contents: nil, attributes: nil)
        let script = try File(path: scriptPath, using: FileManager.default)
        try script.write(string: Bone.rubyScript)
        
        let lists = try self.bones()

        let tuple:(list: BoneSpec, bone: BoneItem)? = lists
            .filter { listName.count == 0 || $0.name == listName }
            .reduce(nil) { acc, list in
                if acc != nil { return acc }
                //            let folder = try bonesFolder.subfolder(named: list.name)
                //            let bonelist = try self.bonespec(from: folder)

                if let rootBone = list.bones[boneName] {
                    return (list, rootBone)
                } else {
                    return nil
                }
        }
        guard let root = tuple else {
            throw Error.unknownBone
        }
        
        let boneList = root.list
        let rootBone = root.bone

        if boneList.isLocal {
            guard let localFolder = try? fs.currentFolder.subfolder(named: murrayLocalTemplatesFolderName) else {
                throw Error.missingLocalSubfolder
            }
            bonesFolder = localFolder
        }

        Logger.log(bonesFolder.path, level: .verbose)
        guard
            let templatesFolder = try? bonesFolder.subfolder(named: boneList.name).subfolder(atPath: boneList.sourcesBaseFolder) else {
                throw Error.missingSubfolder
        }
        
        var context:[String: Any] = [:]
        //TODO convert inputstring into dictionary
        
        
        try self.createSubBone(boneList: boneList, bone: rootBone, templatesFolder: templatesFolder, name: name, fs: fs, context: context)

    }

    private static func createSubBone(boneList: BoneSpec, bone: BoneItem, templatesFolder: Folder, name: String, fs: FileSystem, context:[String: Any]) throws {
        var context = context
        context["name"] = context["name"] ?? name
        
        Logger.log("Starting \(bone.name) bone", level: .verbose)
        if bone.files.count > 0 {
            let scriptPath = "\(Bone.murrayTemplatesFolderName)/script.rb"
            let subfolders = boneList.folders + bone.folders
            Logger.log("Subfolders: \(subfolders)", level: .verbose)
            let sourcesFolder: Folder? = subfolders.reduce(fs.currentFolder) { acc, current -> Folder? in
                guard let f = acc else { return nil }
                return try? f.subfolder(named: current)
            }
            Logger.log("SourcesFolder: \(sourcesFolder?.path ?? "unknown")", level: .verbose)
            guard let containingFolder = sourcesFolder else {
                throw Error.missingSubfolder
            }

            guard let finalFolder =
                bone.createSubfolder == false ? containingFolder :
                    (try? containingFolder.subfolder(named: name)) ?? (try? containingFolder.createSubfolder(named: name)) else {
                        throw Error.missingSubfolder
            }
            Logger.log("Parsing \(bone.name) files", level: .verbose)
            try bone.files.forEach { path in
                Logger.log(templatesFolder.path + "/" + path, level: .verbose)

                guard let templateFile = try? templatesFolder.file(named: path) else {
                    throw Error.missingFile
                }
                Logger.log("Moving to destination", level: .verbose)
                guard let file = try? templateFile.copy(to: finalFolder) else {
                    throw Error.missingFile
                }
                Logger.log("Renaming", level: .verbose)
                let placeholder = bone.placeholder
                if placeholder.count > 0 {
                    if let filename = path.split(separator: "/").last {
                        try file.rename(to: filename.replacingOccurrences(of: placeholder, with: name))
                    }
                    Logger.log("Reading file", level: .verbose)
                    var string = try file.readAsString()
                    let template = FileTemplate(fileContents: string, context: context)
                    let rendered = try template.render()
//                    let innerPlaceholder = "___\(placeholder)Placeholder___"
//                    let innerPlaceholderLowercased = "___\(placeholder)PlaceholderFirstLowercased___"
//                    string = string
//                        .replacingOccurrences(of: innerPlaceholder, with: name)
//                        .replacingOccurrences(of: innerPlaceholderLowercased, with: name.firstLowercased())
//                    Logger.log("Writing file", level: .verbose)
                    try file.write(string: rendered)
                }
                Logger.log("Current folder: \(fs.currentFolder.path)", level: .verbose)

                if bone.targetNames.count > 0 {
                    let projectName = fs.currentFolder.subfolders
                        .filter ({ $0.name.contains(".xcodeproj") })
                        .map ({ $0.nameExcludingExtension }).first
                    Logger.log("Editing project \"\(projectName ?? "")\"", level: .verbose)
                    if let projectName = projectName,
                        bone.targetNames.count > 0 {

                        let args = [
                            scriptPath,
                            projectName,
                            file.path,
                            "\"\((boneList.folders + bone.folders + ([(bone.createSubfolder ? name : nil)].compactMap { $0 })).filter {$0.count > 0}.joined(separator: "|"))\"",
                            "\"\((bone.targetNames).joined(separator: "|"))\""
                        ]
                        Logger.log("Updating xcodeproj with arguments: \(args)", level: .verbose)
                        try shellOut(to: "ruby",
                                     arguments: args)
                    }
                }
            }
        }
        Logger.log("Parsing \(bone.name) subBones", level: .verbose)
        try bone.subBones.compactMap {
            boneList.bones[$0]
            }.forEach {
                try self.createSubBone(boneList: boneList, bone: $0, templatesFolder: templatesFolder, name: name, fs: fs, context: context)
        }
    }
}

fileprivate extension Bone {
    static let rubyScript = """

        require 'xcodeproj'
        project_name = ARGV[0]
        file_path = ARGV[1]
        destination_folder_string = ARGV[2]
        targets_string = ARGV[3]

        destination_folders = destination_folder_string.split('|')
        target_names = targets_string.split('|')

        project_path = "./#{project_name}.xcodeproj"
        project = Xcodeproj::Project.open(project_path)

        reference = project
        path = "./"
        destination_folders.each do |f|
          path = path + "/" + f
          if reference[f] != nil
            reference = reference[f]
          else
            reference = reference.new_group(f, f, :group)
          end
        end

        file = Xcodeproj::Project::Object::FileReferencesFactory.new_reference(reference , file_path , :group)

        reference << file

        project.targets
                .select { |t| target_names.include?(t.name)}
                .each do |t|
                  t.source_build_phase.add_file_reference(file)
                end
        project.save
    """
}