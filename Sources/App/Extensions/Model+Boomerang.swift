//
//  Model+Boomerang.swift
//  App
//
//  Created by Umberto Lanno on 01/06/2018.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import Boomerang
import ModelLayer

protocol ModelWithTitle: ModelType {
    var title: String { get }
}

extension String: ModelWithTitle {
    public var title: String { return self }
}

//Example
//extension Product : ModelType {}
