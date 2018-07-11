import RxSwift
import Action
import UIKit
import Boomerang

enum SelectionValue : Boomerang.SelectionInput, Boomerang.SelectionOutput {
    case start
    case reload
    case restart
    case openURL(URL)
    case model(ModelType)
    case viewModel(ViewModelType)
    case item(IndexPath)
    case invalidateLayout
    case dismiss
    case openPicker
}

typealias SelectionInput = SelectionValue
typealias SelectionOutput = SelectionValue
typealias Selection = Action<SelectionInput,SelectionOutput>

protocol SelectableViewModelType : ViewModelType {
    var selection : Selection { get }
}

extension SelectableViewModelType {
    
    func baseSwitch(input: SelectionInput) -> Observable<SelectionOutput>? {
        
        switch input {
        case .openPicker :
            if let picker = self as? SceneViewModelType {
                return .just(.viewModel(picker))
            }
        default: return .just(input)
            
        }
        return nil
    }
    
    func generateSelection() -> Selection {
        return Selection {[weak self] input in
            return self?.baseSwitch(input: input) ?? .empty()
        }
    }
}
