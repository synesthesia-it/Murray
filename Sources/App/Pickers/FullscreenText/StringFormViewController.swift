//
//  StringFormViewController.swift
//  App
//
//  Created by Stefano Mondino on 06/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import SnapKit
import IHKeyboardAvoiding

class StringFormViewController: UIViewController, ViewModelBindable, SelectableViewController {
    var keyboardAvoidingView: UIView {
        return textView
    }
    var textView: UITextView = UITextView(frame: .zero)
    var viewModel: ViewModelType?
    var bottomConstraint:Constraint?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            self.bottomConstraint = make.bottom.equalToSuperview().constraint
        }
        textView.font = UIFont.type(type: .roboto, weight: .regular, size: TextTheme.dark.fontSize)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.textView.resignFirstResponder()
        super.viewWillDisappear(true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        KeyboardAvoiding.avoidingBlock = {[weak self] flag, f1, f2, options in
            self?.bottomConstraint?.layoutConstraints.forEach { $0.constant = -f2 }
        }
        textView.becomeFirstResponder()
        
    }
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? StringPickerItemViewModel else { return }
        self.viewModel = viewModel
        self.navigationItem.title = viewModel.title
        viewModel.value.bind(to: textView.rx.text).disposed(by: disposeBag)
        let save = UIBarButtonItem(title: "button-save-text".localized(), style: .done, target: nil, action: nil)
        save.rx.tap.subscribe(onNext: {[weak self] in
            viewModel.value.accept(self?.textView.text ?? "")
            self?.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
        self.navigationItem.rightBarButtonItem = save
    }
}
