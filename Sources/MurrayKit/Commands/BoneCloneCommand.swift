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

        let repository = Repository(repo: url)
        let tmpFolderName = "murray.bonecheckout"
        try clone(from: repository, into: Folder.temporary, projectName: tmpFolderName)
        
        guard let tmpFolder = try Folder.temporary.subfolder(at: tmpFolderName).subfolders.first else {
            throw CustomError.generic
        }
        guard let specFolder = try tmpFolder.subfolders.first(where: {
            try $0.decodable(BoneSpec.self, at: "BoneSpec.json") != nil
        }) else {
            throw CustomError.generic
        }
        
        try tmpFolder.subfolder(at: ".git").delete()
        
        let destinationFolder = try self.folder.createSubfolderIfNeeded(at: targetFolder)
        
        try specFolder.move(to: destinationFolder)
        
        let path = try destinationFolder.file(at: "BoneSpec.json").path
        let name = try destinationFolder.decodable(BoneSpec.self, at: "BoneSpec.json")?.name ?? ""
        
        try BoneSpecScaffoldCommand(path: path, name: name).execute()
        
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
