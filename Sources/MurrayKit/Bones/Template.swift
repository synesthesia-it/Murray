//
//  Template.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Foundation
import Files
import ShellOut
import Commander




public final class Template {
    
    static func commands(for group:Group) {
        group.group("template") {
            $0.command(
                "install",
                //                Argument<String>("setup", description: "Setup templates in current folder"),
                Option<String>("boneFile", default:"", description:"Project's Bonefile"))
            {
                git in
                try Template.setup()
            }
            
            $0.command("list") {
                try Template.list()
            }
            
            $0.command("create",
                       Argument<String>("boneName", description:""),
                       Argument<String>("filenames", description:"Filenames separated by | "),
                       Option<String>("specName", default:"Custom", description:"")
                )
            { name, files, listName in
                try Template.newBone(listName: listName, name: name, files: files.components(separatedBy: "|"))
            }
            
            $0.command("new",
                       Argument<String>("bone", description:""),
                       Argument<String>("name", description:""),
                       Option<String>("boneListName", default:"", description:""),
                       Option<String>("targetName", default:"", description:"")
                )
            { bone, name, listName, targetName in
                try Template.newTemplate(bone: bone, name: name, listName:listName, targetName:targetName)
                
            }
        }
    }
    private static let murrayTemplatesFolderName = ".murray"
    private static let murrayLocalTemplatesFolderName = "MurrayTemplates"
    
    public static func setup() throws {
        let fs = FileSystem()
        Logger.log("Removing old setup", level: .verbose)
        try? FileManager.default.removeItem(atPath: murrayTemplatesFolderName)
        
        guard let folder = try? fs.createFolder(at: murrayTemplatesFolderName) else {
            throw Error.existingFolder
        }
        let urls = try self.urlsFromBonefile()
        let fileManager = FileManager.default
        try urls.forEach { git in
            //File manager path should always restored to its original value after execution.
            //This helps testing and doesn't allow any subsequent operation to depend upon directory switching
            let defaultFolder = fileManager.currentDirectoryPath
            defer {
                fileManager.changeCurrentDirectoryPath(defaultFolder)
            }
            fileManager.changeCurrentDirectoryPath(folder.path)
            Logger.log("Cloning bones app from \(git.absoluteString)", level: .normal)
            
            try shellOut(to:.gitClone(url:git))
            guard let boneFolder = folder.subfolders.first else {
                throw Error.missingSubfolder
            }
            //try? folder.subfolders.first?.moveContents(to: folder)
            _ = try bonespec(from: boneFolder)
        }
        
    }
    
    static func remoteBones() throws -> [BoneList]  {
        let fs = FileSystem()
        guard let bonesFolder = try? fs.currentFolder.subfolder(named: murrayTemplatesFolderName) else {
            throw Error.missingSetup
        }
        return try bonesFolder.subfolders.map { boneFolder in
            return try self.bonespec(from: boneFolder)
        }
    }
    
    static func localBones() throws -> [BoneList]?  {
        let fs = FileSystem()
        guard let bonesFolder = try? fs.currentFolder.subfolder(named: murrayLocalTemplatesFolderName) else {
            return nil
        }
        return try bonesFolder.subfolders.map { boneFolder in
            let spec = try self.bonespec(from: boneFolder)
            spec.isLocal = true
            return spec
        }
    }
    static func bones() throws -> [BoneList] {
        return try remoteBones() + (localBones() ?? [])
    }
    public static func list() throws {
        try self.bones().forEach { spec in
            Logger.log("Spec detail: \(spec.printableDescription)", level: .none)
        }
    }
    
    public static func newBone(listName:String = "Custom", name:String, files:[String]) throws {
        
        let fs = FileSystem()
        guard let bonesFolder = try? fs.currentFolder.createSubfolderIfNeeded(withName: murrayLocalTemplatesFolderName) else {
            throw Error.missingSubfolder
        }
        
        guard let listFolder = try? bonesFolder.createSubfolderIfNeeded(withName: listName) else {
            throw Error.missingSubfolder
        }
        
        guard let spec = try? listFolder.createFileIfNeeded(withName: "Bonespec.json") else {
            throw Error.missingBonespec
        }
        let list:BoneList
        if let data = try? spec.read() {
            do {
                list = try JSONDecoder().decode(BoneList.self, from: data)
                list.bones.forEach { (key,value) in
                    value.name = key
                }
            } catch let error {
                //                print (error)
                //                throw Error.bonespecParsingError
                Logger.log(error.localizedDescription, level: .error)
                list = BoneList.list(name: listName)
            }
        } else {
            list = BoneList.list(name: listName)
        }
        
        let bone = BoneList.Bone(name: name, files: files)
        if list.bones[name] != nil {
            //TODO existing bone
            throw Error.existingFolder
        }
        //        list.bones[name] = bone
        list.append(bone: bone)
        guard let nameFolder = try? listFolder.createSubfolderIfNeeded(withName: name) else {
            throw Error.missingSubfolder
        }
        
        try files.forEach {
            try nameFolder.createFile(named: $0)
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let jsonData = try? encoder.encode(list) else {
            //TODO proper error
            throw Error.missingBonespec
        }
        
        guard let string = String(data:jsonData, encoding: .utf8) else {
            //TODO proper erro
            throw Error.missingBonespec
        }
        
        
        try spec.write(string: string)
        
    }
    
    private static func urlsFromBonefile() throws -> [URL]  {
        let fs = FileSystem()
        guard let boneFile = try? fs.currentFolder.file(named: "Bonefile") else {
            throw Error.missingBonefile
        }
        let contents = try boneFile.readAsString()
        return Set(
            contents.components(separatedBy: "\n")
                .map {$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)}
                .filter {$0.count > 0}
                .compactMap { string in
                    let strings = string.components(separatedBy: " ")
                    guard let command = strings.first,
                        strings.count == 2,
                        command == "bone"
                        else { return nil }
                    
                    return strings.last?.replacingOccurrences(of: "\"", with: "")
                    
                }
                .compactMap { URL(string: $0) }
            )
            .map {$0}
        
    }
    
    private static func bonespec(from folder:Folder) throws -> BoneList  {
        Logger.log("Looking for Bonespec", level: .verbose)
        guard let spec = try? folder.file(named: "Bonespec.json") else {
            throw Error.missingBonespec
        }
        Logger.log("Reading Bonespec", level: .verbose)
        guard let data = try? spec.read() else {
            throw Error.missingBonespec
        }
        Logger.log("Parsing Bonespec", level: .verbose)
        
        do {
            let list = try JSONDecoder().decode(BoneList.self, from: data)
            list.bones.forEach { (key,value) in
                value.name = key
            }
            return list
        } catch let error {
            Logger.log(error.localizedDescription, level: .verbose)
            throw Error.bonespecParsingError
        }
    }
    
    
    
    private static func createSubBone(boneList:BoneList, bone:BoneList.Bone,templatesFolder:Folder, name:String, fs:FileSystem) throws {
        
        Logger.log("Starting \(bone.name) bone", level: .verbose)
        if bone.files.count > 0 {
            let scriptPath = "\(Template.murrayTemplatesFolderName)/script.rb"
            let subfolders = boneList.folders + bone.folders
            Logger.log("Subfolders: \(subfolders)", level: .verbose)
            let sourcesFolder:Folder? = subfolders.reduce(fs.currentFolder) { acc, current -> Folder? in
                guard let f = acc else { return nil }
                return try? f.subfolder(named:current)
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
                Logger.log(templatesFolder.path + "/" + path , level: .verbose)

                guard let templateFile = try? templatesFolder.file(named: path) else {
                    throw Error.missingFile
                }
                Logger.log("Moving to destination" , level: .verbose)
                guard let file = try? templateFile.copy(to: finalFolder) else {
                    throw Error.missingFile
                }
               Logger.log("Renaming" , level: .verbose)
                let placeholder = bone.placeholder
                if placeholder.count > 0 {
                    if let filename = path.split(separator: "/").last {
                        try file.rename(to: filename.replacingOccurrences(of: placeholder, with: name))
                    }
                    Logger.log("Reading file" , level: .verbose)
                    var string = try file.readAsString()
                    
                    let innerPlaceholder = "___\(placeholder)Placeholder___"
                    let innerPlaceholderLowercased = "___\(placeholder)PlaceholderFirstLowercased___"
                    string = string
                        .replacingOccurrences(of: innerPlaceholder, with: name)
                        .replacingOccurrences(of: innerPlaceholderLowercased, with: name.firstLowercased())
                    Logger.log("Writing file" , level: .verbose)
                    try file.write(string: string)
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
                            "\"\((boneList.folders + bone.folders + ([(bone.createSubfolder ? name : nil)].compactMap{ $0 })).filter {$0.count > 0}.joined(separator:"|"))\"",
                            "\"\((bone.targetNames).joined(separator:"|"))\"",
                        ]
                        Logger.log("Updating xcodeproj with arguments: \(args)", level: .verbose)
                        try shellOut(to: "ruby",
                                     arguments:args)
                    }
                }
            }
        }
        Logger.log("Parsing \(bone.name) subBones", level: .verbose)
        try bone.subBones.compactMap {
            boneList.bones[$0]
            }.forEach {
                try self.createSubBone(boneList: boneList, bone: $0, templatesFolder: templatesFolder, name: name, fs: fs)
        }
    }
    
    private static func newTemplate(bone boneName:String, name:String, listName:String, targetName:String) throws {
        let fs = FileSystem()
        
        guard var bonesFolder = try? fs.currentFolder.subfolder(named: murrayTemplatesFolderName) else {
            throw Error.missingSetup
        }
        let scriptPath = "\(murrayTemplatesFolderName)/script.rb"
        FileManager.default.createFile(atPath: scriptPath, contents: nil, attributes: nil)
        let script = try File(path: scriptPath, using: FileManager.default)
        try script.write(string: Template.rubyScript)
        
        let lists = try self.bones()
        
        let tuple:(list:BoneList,bone:BoneList.Bone)? = lists
            .filter { listName.count == 0 || $0.name == listName }
            .reduce(nil) { acc, list in
                if acc != nil { return acc }
                //            let folder = try bonesFolder.subfolder(named: list.name)
                //            let bonelist = try self.bonespec(from: folder)
                
                if let rootBone = list.bones[boneName] {
                    return (list,rootBone)
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
        try self.createSubBone(boneList: boneList, bone: rootBone, templatesFolder: templatesFolder, name: name, fs: fs)
        
    }
    
}

fileprivate extension Template {
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



public extension Template {
    enum Error: String, Swift.Error, CustomStringConvertible {
        case missingSetup
        case missingFile
        case missingSubfolder
        case missingLocalSubfolder
        case missingProjectName
        case existingFolder
        case gitError
        case shellError
        case missingBonespec
        case missingBonefile
        case bonespecParsingError
        case unknownBone
        public var description: String {
            return self.rawValue
        }
        public var localizedDescription: String {
            return self.rawValue
        }
    }
}
