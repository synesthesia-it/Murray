//
//  File.swift
//  
//
//  Created by Stefano Mondino on 19/05/22.
//

import Foundation

struct Strings {
    private init() {}
    
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
}

@propertyWrapper
struct Translation {
    let key: String
    init(_ key: String) {
        self.key = key
    }
    var wrappedValue: String { key }
}
