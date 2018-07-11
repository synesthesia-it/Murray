//
//  ListPickerElementItemView.swift
//  App
//
//  Created by Stefano Mondino on 08/06/18.
//Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa

class ListPickerElementItemView: UIView, ViewModelBindable, EmbeddableView {

    var viewModel: ItemViewModelType?
    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? ListPickerElementItemViewModel else {
            return
        }
        self.viewModel = viewModel
        self.label.text = viewModel.itemTitle
    }
}
