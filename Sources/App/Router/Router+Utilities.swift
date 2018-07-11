//
//  Router+Utilities.swift
//  MyTest
//
//  Created by Stefano Mondino on 04/07/17.
//  Copyright © 2017 stefanomondino.com. All rights reserved.
//

import Foundation
import UIKit
import Boomerang
import AVKit
import AVFoundation

extension Router {
    
    public static func playVideo<Source> (_ url:URL?, from source:Source) -> RouterAction
        where Source: UIViewController {
            guard let urlFormatted:URL = URL(string:url?.absoluteString.removingPercentEncoding ?? "") else {
                return EmptyRouterAction()
            }
            
            let playerController = AVPlayerViewController()
            let asset:AVURLAsset = AVURLAsset(url: urlFormatted, options: [:])
            
            return UIViewControllerRouterAction.modal(source: source, destination: playerController, completion: {
                let playerItem:AVPlayerItem =  AVPlayerItem(asset: asset)
                playerController.player = AVPlayer(playerItem: playerItem)
                playerController.player?.play()
            })
    }
}

extension UIViewControllerRouterAction {
    
    static func replaceRootWith(destination:UIViewController) -> RouterAction {
        return UIViewControllerRouterAction.custom {
            UIApplication.shared.delegate?.window??.rootViewController = destination
        }
    }
}
