//
//  Response+Error.swift
//  ModelLayer
//
//  Created by Stefano Mondino on 11/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Gloss

extension Observable where Element : Response {
    
    public func mapResponseError() -> Observable<Response> {
        
        return self.flatMap { response -> Observable<Response> in
            do {
                let filtered = try response.filterSuccessfulStatusAndRedirectCodes()
                return Observable<Response>.just(filtered)
            } catch let error {
                if let moyaError = error as? MoyaError,
                    let response = moyaError.response {
                    
                    if let json = try? response.mapJSON() as? JSON,
                        let message = json?["message"] as? String {
                        return .error(APPError.message(message))
                    }
                    
                    switch response.statusCode {
                        
                    default : return .error(APPError.undefined)
                    }
                }
                return .error(error)
            }
            
        }
    }
}
