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
        guard let data: PluginData = self.pluginData(for: item) else { return }
        
        let rubyScript = try projectFolder.createFileIfNeeded(at: ".murray_ruby_script.tmp.rb")
        try rubyScript.write(self.rubyScript())
        
        guard let projectName = projectFolder.subfolders
            .filter ({ $0.name.contains(".xcodeproj") })
            .map ({ $0.nameExcludingExtension }).first else { return }
        
        let targetNames = try data.targets.map { try $0.resolved(with: context) }
        guard targetNames.isEmpty == false else { return }

        let files = try item.paths
            .map { try $0.to.resolved(with: context) }
            .compactMap { try projectFolder.file(at: $0) }
        try files.forEach { file in
            let folders = file.parent?.path(relativeTo: projectFolder).split(separator: "/").joined(separator: "|") ?? ""
            let arguments:[String] = [
                      rubyScript.path,
                      projectName,
                      file.path,
                      "\"\(folders)\"",
                      "\"\(targetNames.joined(separator: "|"))\""
                  ]
            do {
                try shellOut(to: "which", arguments: ["xcodeproj"])
            } catch let error {
                try shellOut(to: "gem", arguments: ["install", "xcodeproj", "--user-install"])
            }
             Logger.log("Updating xcodeproj with arguments: \(arguments)", level: .verbose)
                try shellOut(to: "ruby", arguments: arguments, at: projectFolder.path)
            }
        try rubyScript.delete()
        }
}

extension XCodePlugin {
    func rubyScript() -> String { return  """
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
}
