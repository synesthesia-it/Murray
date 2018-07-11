//
//  SplashViewModel.swift
//  MurrayTest
//
//  Created by Stefano Mondino on 10/07/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import Boomerang
import Action
import RxSwift

class SplashViewModel: SceneViewModelType, SelectableViewModelType {
    
    var sceneIdentifier: SceneIdentifier = .splash
    lazy var selection: Selection = Selection { input in
        switch input {
        case .start :
            //return Observable<SelectionOutput>.just(.viewModel(LoginViewModel()))
            return Observable<SelectionOutput>.empty().delaySubscription(4, scheduler: MainScheduler.instance)
        default : return .empty()
        }
    }
}
