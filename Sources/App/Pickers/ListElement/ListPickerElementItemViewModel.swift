//
//  ListPickerElementItemViewModel.swift
//  App
//
//  Created by Stefano Mondino on 08/06/18.
//Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import RxSwift
import Boomerang
import ModelLayer

final class ListPickerElementItemViewModel: ItemViewModelType {
    var model: ItemViewModelType.Model
    var itemIdentifier: ListIdentifier
    var itemTitle: String?
    init(model: ModelWithTitle, identifier: View = .listPickerElement) {
        self.model = model
        self.itemTitle = model.title
        self.itemIdentifier = identifier
    }
}
