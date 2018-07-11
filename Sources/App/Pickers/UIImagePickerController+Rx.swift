//
//  UIImagePickerController+Rx.swift
//  App
//
//  Created by Stefano Mondino on 06/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Boomerang
import ModelLayer

func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController, animated: animated)
        }

        return
    }

    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}
protocol TitleViewModelType: ViewModelType {
    var title: String { get }
}
class SystemImagePickerViewModel: TitleViewModelType {

    enum PickerType {
        case camera
        case library
        var title: String {
            switch self {
            case .camera : return "alert-shoot-photo"
            case .library : return "alert-choose-from-library"
            }
        }
    }
    var type: PickerType
    var relay: BehaviorRelay<[WithImage]>
    var title: String {
        return type.title
    }
    init(type: PickerType, relay: BehaviorRelay<[WithImage]>) {
        self.type = type
        self.relay = relay
    }
}

extension Reactive where Base: UIImagePickerController {
    static func createWithParent(_ parent: UIViewController?, animated: Bool = true, configureImagePicker: @escaping (UIImagePickerController) throws -> Void = { x in }) -> Observable<UIImagePickerController> {
        return Observable.create { [weak parent] observer in
            let imagePicker = UIImagePickerController()
            let dismissDisposable = imagePicker.rx
                .didCancel
                .subscribe(onNext: { [weak imagePicker] _ in
                    guard let imagePicker = imagePicker else {
                        return
                    }
                    dismissViewController(imagePicker, animated: animated)
                })

            do {
                try configureImagePicker(imagePicker)
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }

            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }

            parent.present(imagePicker, animated: animated, completion: nil)
            observer.on(.next(imagePicker))

            return Disposables.create(dismissDisposable, Disposables.create {
                dismissViewController(imagePicker, animated: animated)
            })
        }
    }
}

#if os(iOS)

import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIImagePickerController {

    /**
     Reactive wrapper for `delegate` message.
     */
    public var didFinishPickingMediaWithInfo: Observable<[String: AnyObject]> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerController(_:didFinishPickingMediaWithInfo:)))
            .map({ (a) in
                return try castOrThrow(Dictionary<String, AnyObject>.self, a[1])
            })
    }

    /**
     Reactive wrapper for `delegate` message.
     */
    public var didCancel: Observable<()> {
        return delegate
            .methodInvoked(#selector(UIImagePickerControllerDelegate.imagePickerControllerDidCancel(_:)))
            .map {_ in () }
    }

}

#endif

#if os(iOS)

import RxSwift
import RxCocoa
import UIKit

extension RxNavigationControllerDelegateProxy: UIImagePickerControllerDelegate {

}
#endif
private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
