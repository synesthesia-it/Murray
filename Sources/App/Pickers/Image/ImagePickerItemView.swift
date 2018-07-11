//
//  ImagePickerItemViewModel.swift
//  App
//
//  Created by Stefano Mondino on 05/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Boomerang

class ImagePickerItemView: UIView, ViewModelBindable, EmbeddableView {

    var viewModel: ViewModelType?

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func bind(to viewModel: ViewModelType?) {

        guard let viewModel = viewModel as? ImagePickerViewModel else { return }
        self.disposeBag = DisposeBag()
        self.viewModel = viewModel
        self.title.text = viewModel.title
        if self.isPlaceholder { return }

        openButton.imageView?.contentMode = .scaleAspectFill
        viewModel.currentImage.asDriver(onErrorJustReturn: UIImage())
            .map {
                $0.size == .zero ? UIImage(named: "ic_add")! : $0
            }
            .drive(openButton.rx.image(for: .normal)).disposed(by: disposeBag)
        
        openButton.rx.tap.asObservable().subscribe(onNext: {_ in
            viewModel.selection.execute(.openPicker)
        }).disposed(by: disposeBag)
        
        viewModel.currentImage.asObservable().map { $0.size == .zero }
            .asDriver(onErrorJustReturn: true)
            .drive(deleteButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        deleteButton.rx.tap.asObservable().subscribe(onNext: {_ in
            viewModel.clear()
        }).disposed(by: disposeBag)
    }

}
