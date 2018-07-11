//
//  ViewController+Selection.swift
//  Test
//
//  Created by Stefano Mondino on 21/04/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Boomerang
import Action
import ModelLayer

protocol SelectableViewController {
    func bind(to selection:Selection)
}

extension ObservableType where E == ActionError {
    public func unwrap() -> Observable<APPError?> {
        return self.map {
            switch $0 {
            case .underlyingError(let error): return error as? APPError
            default: return nil
            }
        }
    }
}

extension SelectableViewController where Self : UIViewController {
    func bind(to selection:Selection) {
        selection.errors.asObservable().unwrap().subscribe(onNext : {[weak self] in
            if let error = $0, let vc = self {
                Router.error(error, from: vc).execute()
            }
        }).disposed(by:self.disposeBag)
        
        selection.executing.debounce(0.1, scheduler: MainScheduler.instance).subscribe(onNext: {[weak self] in
            $0 ? self?.showLoader() : self?.hideLoader()
        }).disposed(by:disposeBag)
        
        selection.elements.asObservable().subscribe(onNext: { [weak self] in
            switch $0 {
            case .invalidateLayout :
                DispatchQueue.main.async {[weak self] in
                    (self as? Collectionable)?.collectionView.performBatchUpdates({
                        (self as? Collectionable)?.collectionView.collectionViewLayout.invalidateLayout()
                    }, completion: nil)
                }
                
            case .viewModel(let viewModel) : Router.from(self!, viewModel:
                viewModel).execute()
                
            case .restart :
                Router.restart()
            default : break
            }
        }).disposed(by:disposeBag)
    }
}
