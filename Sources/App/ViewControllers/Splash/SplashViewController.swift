//
//  SplashViewController.swift
//  App
//
//  Created by Stefano Mondino on 04/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import UIKit
import SnapKit
import Boomerang
import RxSwift
import RxCocoa
import SpinKit

class SplashViewController: UIViewController, ViewModelBindable, SelectableViewController {
    var viewModel: ViewModelType?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()?.view {
//        if let launchScreen = Bundle.main.loadNibNamed("LaunchScreen", owner: nil, options: nil)?.first as? UIView {
            self.view.insertSubview(launchScreen, at: 0)
            launchScreen.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
        }
    }
    func bind(to viewModel: ViewModelType?) {
        guard let viewModel = viewModel as? SplashViewModel else { return }
        self.viewModel = viewModel
        viewModel.selection.execute(.start)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
