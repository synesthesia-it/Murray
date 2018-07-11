//
//  DataManager+Rx.swift
//  ModelLayer
//
//  Created by Stefano Mondino on 11/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire
import Gloss

extension Reactive where Base: DataManager {
    private static func request(_ token: API) -> Observable<Response> {
        return DataManager.provider
            .rx
            .request(token)
            .asObservable()
            .mapResponseError()
    }
    private static func request<T: JSONDecodable>(_ token: API, keyPath: String? = nil) -> Observable<T> {
        guard let keyPath = keyPath else {
            return request(token).mapObject(type: T.self)
        }
        return request(token).mapObject(type: T.self, forKeyPath: keyPath)
    }
    private static func request<T: JSONDecodable>(_ token: API, keyPath: String? = nil) -> Observable<[T]> {
        guard let keyPath = keyPath else {
            return request(token).mapArray(type: T.self)
        }
        return request(token).mapArray(type: T.self, forKeyPath: keyPath)
    }
    
}
