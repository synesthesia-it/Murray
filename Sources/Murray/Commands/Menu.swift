//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Foundation
import Commander
import MurrayKit
public class Menu {
    public static var menu: Group {
        return Group {
            $0.command("start") { Logger.log("test")}
//            Skeleton.commands(for: $0)
            Bone.commands(for: $0)
        }
    }

}
