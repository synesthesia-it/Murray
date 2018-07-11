//
//  Pickers.swift
//  App
//
//  Created by Stefano Mondino on 05/06/18.
//  Copyright © 2018 Synesthesia. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Boomerang
import ModelLayer

protocol PickerItemViewModelType: ItemViewModelType, SelectableViewModelType {
    var currentSelectedTitle: Observable<String> { get }
    var itemIdentifier: ListIdentifier { get set }
    var title: String { get set }
    var enabledIf:Observable<Bool> { get set }
    var placeholder: String { get set }
    var error: ObservableError { get set }
    var externalSelection: Selection? { get set }
    func with(identifier: ListIdentifier) -> Self
}
protocol ListPickerItemViewModelType: PickerItemViewModelType, ListViewModelType, SceneViewModelType {

    func with(dataObservable: Observable<ModelStructure>) -> Self
}

extension ListPickerItemViewModelType {
    var isFormSheet: Bool {
        return true
    }
    func with(dataObservable: Observable<ModelStructure>) -> Self {
        self.dataHolder = ListDataHolder(data: dataObservable)
        return self
    }
    func itemViewModel(fromModel model: ModelType) -> ItemViewModelType? {
        switch model {
        //Example to customize picker for particular models
        //case let model as Product : return ListItemViewModel(product: model)
        case let model as ModelWithTitle : return ListPickerElementItemViewModel(model: model)
        default : return model as? ItemViewModelType
        }
    }
}

class StringPickerItemViewModel: PickerItemViewModel, SceneViewModelType {
    typealias T = String

    var sceneIdentifier: SceneIdentifier = .stringForm
    var itemIdentifier: ListIdentifier = View.text
    var isFullscreen: Bool = false
    var title: String = ""
    var placeholder: String = ""
    var enabledIf: Observable<Bool> = .just(true)
    var value: BehaviorRelay<T> { return self.model as? BehaviorRelay<T> ?? BehaviorRelay(value: "")}

    var externalSelection: Selection?

    var model: ItemViewModelType.Model

    var selection: Selection = Selection { _ in .empty() }

    var error: ObservableError = .just(nil)

    var style: TextStyle = TextStyle(TextStyles.normal)

    init(relay: BehaviorRelay<String>) {
        self.model = relay
    }
    func with(style: TextStyle) -> Self {
        self.style = style
        return self
    }
    func with(fullscreen: Bool) -> Self {
        self.isFullscreen = fullscreen
        return self
    }
}

protocol PickerItemViewModel: PickerItemViewModelType {
    associatedtype T
}
extension PickerItemViewModel {

    var currentSelectedTitle: Observable<String> {
        return .just("")
    }

    func with(externalSelection: Selection) -> Self {
        self.externalSelection = externalSelection
        return self
    }

    func with(title: String) -> Self {
        self.title = title
        return self
    }
    
    func with(placeholder: String) -> Self {
        self.placeholder = placeholder
        return self
    }

    func with(identifier: ListIdentifier) -> Self {
        self.itemIdentifier = identifier
        return self
    }
    func with(error: ObservableError) -> Self {
        self.error = error
        return self
    }
    func with(enabledIf: Observable<Bool>) -> Self {
        self.enabledIf = enabledIf
        return self
    }

    func select(item: T?) {
        switch self.model {
        case let relay as BehaviorRelay<T> :
            if let item = item { relay.accept(item) }
        case let relay as BehaviorRelay<T?> :
            relay.accept(item)
        case let relay as BehaviorRelay<[T]> :
            relay.accept(relay.value + [item].compactMap {$0})
        default : break
        }
    }
    func clear(emptyItem: T? = nil) {
        switch self.model {
        case let relay as BehaviorRelay<T> :
            if let item = emptyItem { relay.accept(item) }
        case let relay as BehaviorRelay<T?> :
            relay.accept(nil)
        case let relay as BehaviorRelay<[T]> :
            relay.accept([])
        default : break
        }
    }
}

class ImagePickerViewModel: ActionSheetViewModel, PickerItemViewModel {

    typealias T = WithImage
    var itemIdentifier: ListIdentifier = View.imagePicker
    var placeholder: String = ""
    let currentImage: Observable<UIImage>
    var model: ItemViewModelType.Model
    var error: ObservableError = .just(nil)
    var enabledIf: Observable<Bool> = .just(true)
    lazy var selection: Selection = Selection {[weak self] input in
        if let sself = self {
            switch input {
            case .openPicker : self?.externalSelection?.execute(.viewModel(sself))
            default : break
            }
        }
        return self?.baseSwitch(input: input) ?? .empty()
    }

    var currentSelectedTitle: Observable<String> {
        return .just("")
    }

     init(array relay: BehaviorRelay<[WithImage]>) {
        self.currentImage = relay.asObservable().flatMapLatest { $0.first?.getImage() ?? .just(UIImage()) }
        self.model = relay
        super.init(title: "image-picker-title".localized(), message: "image-picker-message".localized(), viewModels: [
            SystemImagePickerViewModel(type: .camera, relay: relay),
            SystemImagePickerViewModel(type: .library, relay: relay)
            ])
    }
}

class ModelPickerViewModel<T: ModelWithTitle> : ListPickerItemViewModelType, PickerItemViewModel {
    var currentSelectedTitle: Observable<String>
    var itemIdentifier: ListIdentifier = View.text
    var title: String = ""
    var placeholder: String = ""
    var error: ObservableError = .just(nil)
    var externalSelection: Selection?
    var sceneIdentifier: SceneIdentifier = .listForm
    var dataHolder: ListDataHolderType = ListDataHolder()
    var enabledIf: Observable<Bool> = .just(true)
    var model: ItemViewModelType.Model

    lazy var selection: Selection = Selection {[weak self] input in
        if let sself = self {
            switch input {
            case .openPicker :
                self?.externalSelection?.execute(.viewModel(sself))
                return .empty()
            case .item(let indexPath) :
                if let model = self?.model(atIndex: indexPath) as? T {
                    sself.select(item: model)
                    return .just(.dismiss)
                }
            default : break
            }
        }
        return self?.baseSwitch(input: input) ?? .empty()
    }

    init(relay: BehaviorRelay<T?>) {
        self.model = relay
        currentSelectedTitle = relay.asObservable().map { $0?.title ?? "" }
    }
    init(relay: BehaviorRelay<T>) {
        self.model = relay
        currentSelectedTitle = relay.asObservable().map { $0.title }
    }
    func with(sceneIdentifier identifier: SceneIdentifier) -> Self {
        self.sceneIdentifier = identifier
        return self
    }
}

class ActionSheetViewModel: SceneViewModelType {
    var sceneIdentifier: SceneIdentifier = .none
    var actions: () -> [UIAlertAction] = {  [] }
    var title: String = ""
    var message: String = ""
    
    //this is useful for method composition, do not remove
    //the "withExternalSelection" method of picker actually populates this value
    var externalSelection: Selection?
    
    init(title: String = "", message: String = "", viewModels: [TitleViewModelType] = [], externalSelection: Selection? = nil) {
        self.title = title
        self.message = message
        self.externalSelection = externalSelection
        
        self.actions = { viewModels.map {vm in
            UIAlertAction(title: vm.title.localized(), style: .default, handler: {[weak self] (_) in
                //in some cases the actionsheet viewmodel is deallocated before the action is called.
                (self?.externalSelection ?? externalSelection)?.execute(.viewModel(vm))
            })
            } + [UIAlertAction(title: "alert-cancel".localized(), style: .cancel, handler: nil)]
        }
        
    }
}
