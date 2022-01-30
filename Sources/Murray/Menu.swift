//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Commander
import Foundation
import MurrayKit

public enum Murray {
    public static var commands: Group {
        return Group {
            $0.command("hello") { print("hello?") }
//            Skeleton.commands(for: $0)
//            Bone.commands(for: $0)
//            Scaffold.commands(for: $0)
        }
    }
}
