//
//  Utilities.swift
//  MurrayTests
//
//  Created by Stefano Mondino on 04/01/2019.
//

import Foundation

public extension String {
    func firstLowercased() -> String {
        return self.prefix(1).lowercased() + self.dropFirst()
    }
    func firstUppercased() -> String {
        return self.prefix(1).uppercased() + self.dropFirst()
    }
}
