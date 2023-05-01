//
//  File.swift
//
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation
// swiftlint:disable identifier_name line_length
extension String {
    @Translation("Print complete log during command execution")
    static var verboseDescription: String

    @Translation("A set of commands to interact with bones in current folder")
    static var boneDescription: String

    @Translation("List all available bones.")
    static var listDescription: String

    @Translation("Run selected procedure in current folder")
    static var runDescription: String

    @Translation("Name of the bone from bonespec (example: model). If multiple bonespecs are being used, use <bonespecName>.<boneName> syntax. Example: myBones.model")
    static var runNameDescription: String

    @Translation("Value that needs to be replaced in templates wherever the keyword <name> is used.")
    static var runMainPlaceholderDescription: String

    @Translation("Previews results instead of actually execute it")
    static var runPreviewDescription: String

    @Translation("Custom parameters for templates. Use key:value syntax (ex: \"author:yourname with spaces\")")
    static var runParametersDescription: String

    @Translation("Create a new Murrayfile in current folder")
    static var scaffoldMurrayfileDescription: String

    @Translation("Create a new Skeleton in current folder")
    static var scaffoldSkeletonfileDescription: String

    @Translation("Create a new Package in specified folder")
    static var scaffoldPackageDescription: String

    @Translation("Package name")
    static var scaffoldPackageNameDescription: String

    @Translation("Default folder containing all Murray packages, relative to Murrayfile directory.")
    static var scaffoldPackageFolderDescription: String

    @Translation("A package named %@ created from scaffold")
    static var scaffoldPackageDefaultDescriptionFormat: String

    @Translation("An item named %@ created from scaffold")
    static var scaffoldItemDefaultDescriptionFormat: String

    @Translation("An procedure named %@ created from scaffold")
    static var scaffoldProcedureDefaultDescriptionFormat: String

    @Translation("Create a new item in specified package.")
    static var scaffoldItemDescription: String

    @Translation("Name of item to be created")
    static var scaffoldItemNameDescription: String
    @Translation("Name of package where current item will be included into")
    static var scaffoldItemPackageNameDescription: String

    @Translation("File names to be created (empty) and associated to current item")
    static var scaffoldItemFilesDescription: String

    @Translation("Skip automatic procedure creation for current item.")
    static var scaffoldItemSkipProcedureDescription: String

    @Translation("Create a new procedure in specified package with provided items in sequence.")
    static var scaffoldProcedureDescription: String
    @Translation("Name of package where procedure will be included into")
    static var scaffoldProcedurePackageNameDescription: String
    @Translation("Name of the procedure that will be used in run command")
    static var scaffoldProcedureNameDescription: String
    @Translation("Item names to include in this procedure")
    static var scaffoldProcedureItemsDescription: String

    @Translation("File format for file. Can be yml or json. Defaults to yml.")
    static var scaffoldFileFormatDescription: String

    @Translation("Clone a remote repository containing a Skeleton file")
    static var cloneDescription: String

    @Translation("A path pointing to a valid git repository, either local or remote. To specify a custom branch/tag, use @<tag> or @<branch> or @<commit_id> right after the url. \nExample: https://github.com/synesthesia-it/Murray@develop")
    static var cloneGitDescription: String

    @Translation("Provided path should be intended as a local folder, ignoring git status, copy folder as-is. This is useful for local development to avoid committing every test.")
    static var cloneForceLocalPathDescription: String

    @Translation("A subfolder path containing the actual Skeleton project. This is useful when the same repository contains more than one Skeleton,")
    static var cloneGitSubfolderDescription: String
}

@propertyWrapper
struct Translation {
    let key: String
    init(_ key: String) {
        self.key = key
    }

    var wrappedValue: String { key }
}
