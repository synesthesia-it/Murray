//
//  View.swift
//  MurrayTest
//
//  Created by Stefano Mondino on 10/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import Boomerang

enum View: String, ListIdentifier {
    
    case test
    
    //Pickers
    case listPickerElement
    case text
    case imagePicker
    
    var isEmbeddable: Bool { return true }
    
    var name: String {
        switch self {
        default : return self.rawValue.capitalizingFirstLetter() + "ItemView"
        }
    }
    
    var view: (UIView & ViewModelBindableType)? {
        return Bundle.main.loadNibNamed(self.name, owner: nil, options: nil)?.first as? (UIView & ViewModelBindableType)
    }
}
