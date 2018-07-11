//
//  Router+Alert.swift
//  MyTest
//
//  Created by Stefano Mondino on 04/07/17.
//  Copyright © 2017 stefanomondino.com. All rights reserved.
//

import Boomerang
import UIKit
import ModelLayer

extension Router {
    public static func confirm<Source:UIViewController>(title:String,message:String,confirmationTitle:String, from source:Source, action:@escaping (() -> Void)) -> RouterAction {
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        return UIViewControllerRouterAction.modal(source: source, destination: alert, completion: nil)
    }
    
    public static func error<Source:UIViewController>(_ error:APPError, from source:Source) -> RouterAction {
        let alert = UIAlertController(title:error.title, message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil))
        return UIViewControllerRouterAction.modal(source: source, destination: alert, completion: nil)
    }
    public static func actions<Source:UIViewController>(fromSource source:Source, item:UIBarButtonItem, actions:[UIAlertAction]) -> RouterAction {
        let alert = UIAlertController(title:nil, message: nil, preferredStyle: .actionSheet)
        
        _ = actions.reduce(alert) { (accumulator, action)  in
            accumulator.addAction(action)
            
            return accumulator
        }
        alert.modalPresentationStyle = .popover
        let popover = alert.popoverPresentationController!
        popover.permittedArrowDirections = .up
        popover.barButtonItem = item
        return UIViewControllerRouterAction.modal(source: source, destination: alert, completion: nil)
        
    }
}
