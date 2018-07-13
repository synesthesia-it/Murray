//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Foundation
import Commander

public class Menu {
    public static var menu : Group {
        return Group {
            Project.commands(for: $0)
            Template.commands(for: $0)
        }
    }
    
    
    
}
