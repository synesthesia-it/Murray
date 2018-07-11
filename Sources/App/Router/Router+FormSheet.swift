//
//  Router+FormSheet.swift
//  App
//
//  Created by Stefano Mondino on 25/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import Boomerang
import UIKit
import MZFormSheetPresentationController
extension UIViewControllerRouterAction {
    public static func formSheet<Source: UIViewController>(from source:Source, to destination:UIViewController) -> RouterAction {
        return UIViewControllerRouterAction.custom {
            
            let formSheet = MZFormSheetPresentationViewController(contentViewController: destination)
            formSheet.contentViewCornerRadius = 0
            formSheet.presentationController?.dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            formSheet.presentationController?.contentViewSize = CGSize(width: source.view.bounds.width - 88, height: source.view.bounds.height * 0.8)
            
            source.present(formSheet, animated: true, completion: nil)
            
        }
    }
}
