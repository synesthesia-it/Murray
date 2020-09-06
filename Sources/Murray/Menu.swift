//
//  Menu.swift
//  MurrayCore
//
//  Created by Stefano Mondino on 12/07/18.
//

import Commander
import Foundation
import MurrayKit

public class Murray {
    public static var commands: Group {
        return Group {
            Skeleton.commands(for: $0)
            Bone.commands(for: $0)
            Scaffold.commands(for: $0)
        }
    }
}
