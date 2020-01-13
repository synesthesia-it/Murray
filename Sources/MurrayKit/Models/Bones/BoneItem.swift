import Foundation
import Gloss

public protocol CustomCodable: Codable {}

public struct BoneItem: Glossy {

    public let name: String
    public let paths: [BonePath]
    public let parameters: [BoneParameter]
    
    public init?(json: JSON) {
        guard let name:String = "name" <~~ json else { return nil }
        self.name = name
        self.paths = "paths" <~~ json ?? []
        self.parameters = "parameters" <~~ json ?? []
    }
    
    public func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "paths" ~~> paths,
            "parameters" ~~> parameters
        ])
    }
    
}
