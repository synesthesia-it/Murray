//
//  UIViewController+Utilities.swift
//  MyTest
//
//  Created by Stefano Mondino on 04/07/17.
//  Copyright © 2017 stefanomondino.com. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Boomerang
import MBProgressHUD
import pop
import Action
import SpinKit
import Localize_Swift
import IHKeyboardAvoiding

protocol Collectionable: KeyboardAvoidable {
    var collectionView: UICollectionView! {get}
    func setupCollectionView()
}

protocol Refreshable : Collectionable {
    func setupRefreshable(viewModel:ListViewModelType)
}

protocol KeyboardAvoidable {
    var keyboardAvoidingView: UIView { get }
    func setupKeyboardAvoiding()
}
extension KeyboardAvoidable where Self: UIViewController {
    func setupKeyboardAvoiding() {
        let vc = self as UIViewController
        vc.rx
            .methodInvoked(#selector(UIViewController.viewDidAppear(_:)))
            .subscribe(onNext: {_ in
                KeyboardAvoiding.avoidingBlock = nil
                KeyboardAvoiding.avoidingView = self.keyboardAvoidingView
            })
            .disposed(by: vc.disposeBag)
        
    }
}

extension Collectionable  where Self: UIViewController {
    var keyboardAvoidingView: UIView { return collectionView }
    func setupCollectionView() {
        self.collectionView.backgroundColor = .clear
        
    }
}
extension Refreshable {
    func setupRefreshable(viewModel:ListViewModelType) {
        let refreshControl = UIRefreshControl()
        refreshControl.rx.bind(to: viewModel.dataHolder.reloadAction, input: nil)
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
    }
}
extension UIViewController {
    func withNavigation() -> NavigationController {
        return NavigationController(rootViewController: self)
    }
}

extension ViewModelBindable where Self: UIViewController {
    func withViewModel(_ viewModel: ViewModelType) -> Self {
        self.bind(to: viewModel, afterLoad: true)
        return self
    }
}

extension UIViewController {
    
    private struct AssociatedKeys {
        static var loaderCount = "loaderCount"
        static var disposeBag = "vc_disposeBag"
    }
    
    public var disposeBag: DisposeBag {
        var disposeBag: DisposeBag
        
        if let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
            disposeBag = lookup
        } else {
            disposeBag = DisposeBag()
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        return disposeBag
    }
    
    func setup(with viewModel: ViewModelType) -> UIViewController {
        
        let closure = {[unowned self] in
            
            (self as? Collectionable)?.setupCollectionView()
            
            if let selection = (viewModel as? SelectableViewModelType)?.selection {
                (self as? SelectableViewController)?.bind(to: selection)
            }
            (self as? KeyboardAvoidable)?.setupKeyboardAvoiding()
            (self as? ViewModelBindableType)?.bind(to: viewModel)
            if let list = viewModel as? ListViewModelType {
                (self as? Refreshable)?.setupRefreshable(viewModel: list)
            }
            if ((self.navigationController?.viewControllers.count ?? 0) > 1) {
                _ = self.withBackButton()
            }
            if (self.navigationController?.viewControllers.count ?? 0) == 1 && self.presentingViewController != nil {
                _ = self.withCloseButton()
            }
            
        }
        if (self.isViewLoaded) {
            closure()
        } else {
            _ = self.rx
                //                .methodInvoked(#selector(viewDidLoad))
                .viewDidLoad()
                .take(1)
                //.delay(0.0, scheduler: MainScheduler.instance)
                .subscribe(onNext: {_ in closure()})
        }
        
        return self
    }
    
    @objc func back() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    func withBackButton() -> UIViewController {
        //        let item = UIBarButtonItem(image: UIImage(named: "ic_arrow_back_white"), style: .done, target: self, action: #selector(back))
        let item = UIBarButtonItem(title: "menu-back".localized(), style: .done, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = item
        return self
    }
    
    func withCloseButton() -> UIViewController {
        let item = UIBarButtonItem(title: "menu-cancel".localized(), style: .done, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = item
        return self
    }
    private var loaderCount: Int {
        
        get { return objc_getAssociatedObject(self, &AssociatedKeys.loaderCount) as? Int ?? 0}
        set { objc_setAssociatedObject(self, &AssociatedKeys.loaderCount, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
        
    }
    
    func loaderView() -> UIView {
        return RTSpinKitView(style: .stylePulse, color: UIColor.white, spinnerSize: 44)
    }
    func loaderContentView() -> UIView {
        return self.navigationController?.view ?? self.view
    }
    @objc func showLoader() {
        
        if (self.loaderCount == 0) {
            DispatchQueue.main.async {[unowned self] in
                let hud = MBProgressHUD.showAdded(to: self.loaderContentView(), animated: true)
                let spin = self.loaderView()
                hud.customView = spin
                hud.mode = .customView
                hud.bezelView.color = .clear
            }
            
        }
        self.loaderCount += 1
        
    }
    @objc func hideLoader() {
        DispatchQueue.main.async {[weak self]  in
            if (self == nil) {
                return
            }
            self!.loaderCount = max(0, (self!.loaderCount ) - 1)
            if (self!.loaderCount == 0) {
                MBProgressHUD.hide(for: self!.loaderContentView(), animated: true)
            }
        }
        
    }
    
}
extension Reactive where Base : UIViewController {
    func viewDidLoad() -> Observable<()> {
        return methodInvoked(#selector(UIViewController.viewDidLoad)).map {_ in return ()}
    }
    func viewDidAppear() -> Observable<()> {
        return methodInvoked(#selector(UIViewController.viewDidAppear(_:))).map {_ in return ()}
    }
    func viewWillAppear() -> Observable<()> {
        return methodInvoked(#selector(UIViewController.viewWillAppear(_:))).map {_ in return ()}
    }
    func viewDisappear() -> Observable<()> {
        return methodInvoked(#selector(UIViewController.viewDidDisappear(_:))).map {_ in return ()}
    }
    func viewWillDisappear() -> Observable<()> {
        return methodInvoked(#selector(UIViewController.viewWillDisappear(_:))).map {_ in return ()}
    }
}
