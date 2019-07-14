import MurrayKit
import Dispatch
import Foundation
import Files
import ShellOut

@_cdecl("mainClass")
public func mainClass() -> UnsafeRawPointer {
    return unsafeBitCast(XcodePlugin.self, to: UnsafeRawPointer.self)
}

extension BoneItem {
    var targetNames:[String] {
        if let d: [String: JSONValue] = pluginData.unwrap(),
            let names:[JSONValue] = d["targetNames"]?.unwrap()  {
            return names.compactMap ({ $0.unwrap() })
    }
        return []
}
}

class XcodePlugin: Plugin {
    
    override var pluginName: String {
        return "XcodePlugin"
    }
    
    private var scriptPath: String {
        return  "\(Bone.murrayTemplatesFolderName)/script.rb"
    }
    
    override func initializeBones(context:BonePluginContext) throws {
        Logger.log("Initializing XcodePlugin for bones", level: .verbose)
        FileManager.default.createFile(atPath: scriptPath, contents: nil, attributes: nil)
        let script = try? File(path: scriptPath, using: FileManager.default)
        try script?.write(string: rubyScript())
    }

    
    override func afterReplace(context: BonePluginContext, file: File)throws {
        guard let bone = context.currentBone,
            let boneList = context.boneSpec,
            let name = context.name ?? (context.context["name"] as? String)
            else {
                 Logger.log("Invalid parameters", level: .warning, tag: nil)
                return
        }
        let fs = FileSystem()
        
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
                    "\"\((bone.targetNames.map { (try? $0.resolved(with: context.context )) ?? $0}).joined(separator: "|"))\""
                ]
                Logger.log("Updating xcodeproj with arguments: \(args)", level: .verbose)
                try shellOut(to: "ruby", arguments: args)
            }
        }
        else {
            Logger.log("No target names found", level: .warning, tag: nil)
        }
    }
    override class func getInstance() -> Plugin {
        return XcodePlugin()
    }
}

extension XcodePlugin {
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
