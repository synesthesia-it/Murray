//
//  Scene.swift
//  MurrayTest
//
//  Created by Stefano Mondino on 10/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import Boomerang

protocol SceneViewModelType: ViewModelType, ModelType {
    var isFormSheet:Bool { get }
    var isModal:Bool { get }
    var sceneIdentifier: SceneIdentifier { get }
}
extension SceneViewModelType {
    var isFormSheet:Bool { return false }
    var isModal:Bool { return false }
}

protocol TabSceneViewModelType: SceneViewModelType {
    var sceneTitle: String { get }
    var sceneIcon: UIImage { get }
}

private enum Storyboard {
    case main
    case custom(String)
    var value: String {
        switch self {
        case .main : return "Main"
        case .custom(let s) : return s
        }
    }
    func scene<Type: UIViewController>(_ identifier: SceneIdentifier? = nil) -> Type? {
        guard let identifier = identifier else {
            return UIStoryboard(name: self.value, bundle: nil).instantiateInitialViewController() as? Type
        }
        return UIStoryboard(name: self.value, bundle: nil).instantiateViewController(withIdentifier: identifier.rawValue) as? Type
    }
    
}

enum SceneIdentifier: String, ListIdentifier {
    
    case stringForm
    case splash
    case none
    case listForm
    
    var xibClass: UIViewController.Type? {
        
        switch self {
        case .none : return nil
        default :
            let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
            return NSClassFromString(bundleName + "." + self.rawValue.capitalizingFirstLetter() + "ViewController") as? UIViewController.Type
        }
    }
    
    var name: String {
        guard let xibClass = xibClass else { return self.rawValue }
        return String(describing: xibClass)
    }
    
    var scene: (UIViewController & ViewModelBindableType)? {
        switch self {
        case .none : return nil
        default :
            if let xibClass = xibClass {
                return xibClass.init(nibName: self.name, bundle: nil) as?  (UIViewController & ViewModelBindableType)
            }
            return Storyboard.main.scene(self) as? (UIViewController & ViewModelBindableType)
        }
    }

}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
