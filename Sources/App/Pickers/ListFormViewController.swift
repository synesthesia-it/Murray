//
//  ListFormPickerViewController.swift
//  App
//
//  Created by Stefano Mondino on 25/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import Boomerang
import RxSwift
import RxCocoa
import BonMot

class ListFormViewController: UIViewController, ViewModelBindable, Collectionable, SelectableViewController, KeyboardAvoidable, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    var viewModel: ViewModelType?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        
    }
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? ListPickerItemViewModelType else { return }
        self.viewModel = viewModel
        collectionView.bind(to: viewModel)
        self.titleLabel.text = viewModel.title
        viewModel.reload()
        self.cancelButton.setTitle("menu-cancel".localized(), for: .normal)
        self.cancelButton.rx.tap.asObservable().subscribe(onNext: {_ in
            viewModel.selection.execute(.dismiss)
        }).disposed(by: disposeBag)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (self.viewModel as? SelectableViewModelType)?.selection.execute(.item(indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = collectionView.autosizeItemConstrainedToWidth(at: indexPath, itemsPerLine: 1)
        return CGSize(width: size.width, height: max(40,size.height))
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top:20, left:15, bottom:20, right:15)
    }
    
}

class ListFormPickerViewController: UIViewController, ViewModelBindable, SelectableViewController, UIPickerViewDelegate {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    var viewModel: ViewModelType?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
//        collectionView.delegate = self
//        collectionView.backgroundColor = .clear
        
    }
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? ListPickerItemViewModelType else { return }
        self.viewModel = viewModel
        pickerView.bind(to: viewModel)
        pickerView.delegate = self
        self.titleLabel.text = viewModel.title
        viewModel.reload()
        let picker = self.pickerView
        self.saveButton.setTitle("menu-save".localized(), for: .normal)
        self.cancelButton.setTitle("menu-cancel".localized(), for: .normal)
        self.saveButton.rx.tap.asObservable().subscribe(onNext: {_ in
            if let item = picker?.selectedRow(inComponent: 0) {
                viewModel.selection.execute(.item(IndexPath(item: item, section: 0)))
            }
        }).disposed(by: disposeBag)
        
        self.cancelButton.rx.tap.asObservable().subscribe(onNext: {_ in
            viewModel.selection.execute(.dismiss)
        }).disposed(by: disposeBag)        
        
        self.cancelButton.sizeToFit()
        self.saveButton.sizeToFit()
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let delegate = pickerView.dataSource as? PickerViewCombinedDelegate,
        let title = delegate.pickerView?(pickerView, titleForRow: row, forComponent: component) else { return nil }
        return StringStyle(.font(.type(type: .roboto, weight: .bold, size: 36)),.color(.cadmiumOrange)).attributedString(from: title)
    }
  
}
