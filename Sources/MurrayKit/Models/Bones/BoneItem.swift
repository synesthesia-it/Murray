import Foundation
import Gloss

public protocol CustomCodable: Codable {}

struct BoneItem: Glossy {

    let name: String
    let paths: [BonePath]
    let parameters: [BoneParameter]
    
    init?(json: JSON) {
        guard let name:String = "name" <~~ json else { return nil }
        self.name = name
        self.paths = "paths" <~~ json ?? []
        self.parameters = "parameters" <~~ json ?? []
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "name" ~~> name,
            "paths" ~~> paths,
            "parameters" ~~> parameters
        ])
    }
    
}
