//
//  BoneListCommand.swift
//  MurrayCLI
//
//  Created by Stefano Mondino on 22/01/2020.
//

import Foundation
import Files
import ShellOut

public class BoneCloneCommand: Command {
    
    public var folder: Folder = .current
    
    let url: String
    let targetFolder: String
    
    public init(url: String, targetFolder: String? = nil) {
        self.url = url
        self.targetFolder = targetFolder ?? ".murray"
    }
    
    public func execute() throws {
        do {
            let repository = Repository(package: url)
            let tmpFolderName = "murray.bonecheckout"
            try? Folder.temporary.subfolder(named: tmpFolderName).delete()
            try clone(from: repository, into: Folder.temporary, projectName: tmpFolderName)
            
            let tmpFolder = try Folder.temporary.subfolder(at: tmpFolderName)
            guard let specFolder = tmpFolder.subfolders.first(where: {
                (try? $0.decodable(BonePackage.self, at: BonePackage.fileName)) != nil
            }) else {
                throw CustomError.generic
            }
            
            try? tmpFolder.subfolder(at: ".git").delete()
            
            let destinationFolder = try self.folder
                .createSubfolderIfNeeded(at: targetFolder)
                .createSubfolderIfNeeded(at: specFolder.name)
            
            try specFolder.moveContents(to: destinationFolder)
            
            let path = try destinationFolder.file(at: BonePackage.fileName).path(relativeTo: folder)
//            let name = try destinationFolder.decodable(BoneSpec.self, at: "Bonespec.json")?.name ?? ""
            
            var murrayfile = try folder.decodable(MurrayFile.self, at: MurrayFile.fileName)
            murrayfile?.addSpecPath(path)
            if let json = murrayfile?.toJSON() {
                let data = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
                _ = try folder.createFileWithIntermediateFolders(at: MurrayFile.fileName, contents: data, overwriteContents: true)
            }
        } catch let error {
            throw error
        }
    }
    
    private func clone(from repository: Repository, into folder: Folder, projectName: String) throws {
        
        var command = "git clone --single-branch "
        if repository.version.isEmpty == false {
            command += "--branch \(repository.version) "
        }
        command += repository.repo + " " + folder.path + projectName
        
        try shellOut(to: command)
    }
}
