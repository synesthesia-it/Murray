//
//  Bone.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 16/07/18.
//

import Foundation
import Rainbow

public class BoneItem: Codable {
    public var name = ""

    public var description: String {
        get { return _description ?? "" }
        set { _description = newValue}
    }
    public var files: [String] {
        get {return _files ?? [] }
        set { _files = newValue }
    }
    public var subBones: [String] {
        get { return _subBones ?? [] }
        set { _subBones = newValue }
    }

    public var folders: [String] {
        get {return _folderPath?.components(separatedBy: "/") ?? [] }
        set { _folderPath = newValue.joined(separator: "/")}
    }

    public var placeholder: String {
        get { return _placeholder ?? "Bone" }
        set { _placeholder = newValue }
    }
//    var targetNames: [String] {
//        get {return _targetNames ?? [] }
//        set { _targetNames = newValue }
//    }
    public var createSubfolder: Bool {
        get { return _createSubfolder ?? true }
        set { _createSubfolder = newValue }
    }
    public var placeholderReplaceRule: String {
        get { return _placeholderReplaceRule ?? "{{name}}" }
        set { _placeholderReplaceRule = newValue }
    }
    
    public var otherFilesRules: [BoneReplace] {
        get { return _otherFilesRules ?? [] }
        set { _otherFilesRules = newValue }
    }
    
    public var pluginData: JSONValue {
        get { return _pluginData ?? JSONValue.object([:]) }
        set { _pluginData = newValue}
    }
    
    public var isPrivate: Bool {
        get { return _isPrivate ?? false }
        set { _isPrivate = newValue }
    }
    public var scripts: [String] {
        get { return _scripts ?? [] }
        set { _scripts = newValue }
    }
    
    private var _otherFilesRules: [BoneReplace]?
    private var _createSubfolder: Bool?
    private var _scripts: [String]?
    private var _subBones: [String]?
    private var _isPrivate: Bool?
    private var _files: [String]?
    private var _folderPath: String?
    private var _description: String?
    private var _placeholder: String?
//    private var _targetNames: [String]?
    private var _placeholderReplaceRule: String?
    
    private var _pluginData: JSONValue?
    
    enum CodingKeys: String, CodingKey {
        case _scripts = "scripts"
        case _subBones = "subBones"
        case _files = "files"
        case name = "name"
        case _pluginData = "pluginData"
        case _otherFilesRules = "otherFilesRules"
        case _folderPath = "folderPath"
        case _placeholderReplaceRule = "placeholderReplaceRule"
        case _placeholder = "placeholder"
        case _description = "description"
        case _isPrivate = "isPrivate"
//        case _targetNames = "targets"
        case _createSubfolder = "createSubfolder"
    }

    init(name: String, files: [String]) {
        self.name = name
        self.files = files.map { name + "/" + $0 }
        self.createSubfolder = true
        self.placeholder = "Bone"
        self.folders = []
//        self.pluginData = [:]
        self.subBones = []
        self.scripts = []
        self.description = "Automatically generated by Murray.\nContains \(files.joined(separator: ", "))"
    }
}

public class BoneReplace: Codable {
    enum CodingKeys: String, CodingKey {
        case filePath
        case placeholder
        case text
        case fileTemplate
    }
    public var filePath: String
    public var placeholder: String
    public var text: String
    public var fileTemplate: String?
}


public extension Optional {
    public func resolve(with error: @autoclosure () -> Error) throws -> Wrapped {
        switch self {
        case .none: throw error()
        case .some(let wrapped): return wrapped
        }
    }
    
    func or(_ other: Optional) -> Optional {
        switch self {
        case .none: return other
        case .some: return self
        }
    }
}



public enum JSONValue: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        
        if let v: Int = self.unwrap() { try container.encode(v) }
        if let v: String = self.unwrap() { try container.encode(v) }
        if let v: Double = self.unwrap() { try container.encode(v) }
        if let v: Bool = self.unwrap(){ try container.encode(v) }
        if let v: [String: JSONValue] = self.unwrap()  { try container.encode(v) }
        if let v: [JSONValue] = self.unwrap()  { try container.encode(v) }
        
    }
    
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    
    public func unwrap<T>() -> T? {
        switch self {
        case .string(let s): return s as? T
        case .int(let s): return s as? T
        case .double(let s): return s as? T
        case .bool(let s): return s as? T
        case .object(let obj): return obj as? T
        case .array(let a): return a as? T
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        self = try ((try? container.decode(String.self)).map(JSONValue.string))
            .or((try? container.decode(Int.self)).map(JSONValue.int))
            .or((try? container.decode(Double.self)).map(JSONValue.double))
            .or((try? container.decode(Bool.self)).map(JSONValue.bool))
            .or((try? container.decode([String: JSONValue].self)).map(JSONValue.object))
            .or((try? container.decode([JSONValue].self)).map(JSONValue.array))
            .resolve(with: DecodingError.typeMismatch(JSONValue.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Not a JSON")))
    }
}

public class BoneSpec: Codable {
    private var _bones: [BoneItem]
    public lazy var bones: [String: BoneItem] = {
        return _bones.reduce([:], { a, b in
            var acc = a
            acc[b.name] = b
            return acc
        })
    }()
    func append(_ boneItem: BoneItem) {
        _bones = _bones + [boneItem]
    }
    public var name: String = ""
    public var sourcesBaseFolder: String = ""
    private var destinationBaseFolder: String = "Sources"
    public var folders: [String] {
        get {
            return destinationBaseFolder.components(separatedBy: "/")

        }
    }
    var isLocal = false
    enum CodingKeys: String, CodingKey {
        case _bones = "bones"
        case name
        case destinationBaseFolder
        case sourcesBaseFolder
    }

    var printableDescription: String {
        return self._bones
            .filter { !$0.isPrivate }
            .map { ["\(self.name.blue).\($0.name.green)", $0.description]
                .compactMap {$0}
                .joined(separator: " - ") }
            .joined(separator: "\n\n")
    }

    private init() {
        self._bones = []
    }

    public convenience init(name: String, bones: [BoneItem] = []) {
        self.init()
        self.name = name
        self.isLocal = true
        self.sourcesBaseFolder = ""
        self.bones = bones.reduce([:]) {
            var acc = $0
            acc[$1.name] = $1
            return $0
        }
    }

}
