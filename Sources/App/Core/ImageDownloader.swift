//
//  Image.swift
//  Maze
//
//  Created by Synesthesia on 16/03/2017.
//  Copyright © 2017 Synesthesia. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Gloss
import AlamofireImage

struct ImageDownloader {
    
    private static let downloader = {
        // AlamofireImage's downloader
        return AlamofireImage.ImageDownloader()
    }()
    
    static func  download(_ url: URL) -> Observable<UIImage> {
        return Observable.create { observer in
            let urlRequest = URLRequest(url: url)
            let receipt = downloader.download(urlRequest) { response in
                if let error =  response.result.error {
                    observer.onError(error)
                }
                    observer.onNext(response.result.value ?? UIImage())
                    observer.onCompleted()
            }
            return Disposables.create {
                if receipt != nil {
                    downloader.cancelRequest(with: receipt!)
                }
            }
        }
    }
    
}

protocol WithImage {
    func getImage() -> Observable<UIImage>
}

typealias ObservableImage = Observable<UIImage>

extension UIImage : WithImage {
    func getImage() -> ObservableImage {
        return .just(self)
    }
}
extension URL : WithImage {
    func getImage() -> Observable<UIImage> {
        return ImageDownloader.download(self).catchErrorJustReturn(UIImage())
    }
}
extension String : WithImage {
    func getImage() -> Observable<UIImage> {
        if let url = URL(string: self) {
            return url.getImage()
        }
        guard let img = UIImage(named: self) else { return .just(UIImage())}
        return .just(img)
    }
}
