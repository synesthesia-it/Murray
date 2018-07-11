//
//  API.swift
//  ModelLayer
//
//  Created by Stefano Mondino on 11/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import Moya

enum API: TargetType {
    
    case example
    var baseURL: URL {
        switch self {
        default : return URL(string: "")!
        }
    }
    
    var path: String {
        switch self {
        case .example : return "example"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        default :  return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: .utf8) ?? Data()
    }
    
    var task: Task {
        switch self.method {
        case .get : return Task.requestParameters(parameters: parameters, encoding: URLEncoding.methodDependent)
        case .post, .patch, .put : return Task.requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        default : return Task.requestPlain
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        default : return [:]
        }
    }
    
    var headers: [String: String]? {
        return nil
    }
}
