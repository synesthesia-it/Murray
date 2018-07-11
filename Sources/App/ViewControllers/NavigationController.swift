//
//  NavigationController.swift
//  MyTest
//
//  Created by Stefano Mondino on 04/07/17.
//  Copyright © 2017 stefanomondino.com. All rights reserved.
//

import UIKit

class NavigationController : UINavigationController, UINavigationBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.navigationBar.setBackgroundImage(UIImage.navbar(), for: .default)
        //        self.navigationBar.tintColor = UIColor.white
        //        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : UIFont.helveticaRegular(ofSize: 0) ]
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch UIDevice.current.userInterfaceIdiom {
        default : return .portrait
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
        
    }
    override var shouldAutorotate: Bool {
        return false
    }
}
