import Foundation
import Gloss
/**
    A structure representing a list of file templates to be resolved against BoneContexts and copied to target folders.
 
 */
public struct BoneItem: Glossy {

    public let name: String
    public let paths: [BonePath]
    public let parameters: [BoneParameter]
    public let replacements: [BoneReplacement]
    
    public init?(json: JSON) {
        guard let name:String = "name" <~~ json else { return nil }
        self.name = name
        self.paths = "paths" <~~ json ?? []
        self.parameters = "parameters" <~~ json ?? []
        self.replacements = "replacements" <~~ json ?? []
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "paths" ~~> paths,
            "parameters" ~~> parameters,
            "replacements" ~~> replacements
        ])
    }
    
}

public struct BoneReplacement: Glossy {
    public let placeholder: String
    public let text: String?
    public let sourcePath: String?
    public let destinationPath: String
    
    public init(placeholder: String, text: String, sourcePath: String? = nil, destinationPath: String) {
        self.placeholder = placeholder
        self.text = text
        self.sourcePath = sourcePath
        self.destinationPath = destinationPath
    }
    public init?(json: JSON) {
        guard let placeholder: String = "placeholder" <~~ json,
            let to: String = "destination" <~~ json else { return nil }
        
        self.placeholder = placeholder
        self.destinationPath = to
        self.text = "text" <~~ json
        self.sourcePath = "source" <~~ json
        
        if text == nil && sourcePath == nil { return nil }
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "text" ~~> text,
            "destination" ~~> destinationPath,
            "source" ~~> sourcePath,
            "placeholder" ~~> placeholder
        ])
    }
}
