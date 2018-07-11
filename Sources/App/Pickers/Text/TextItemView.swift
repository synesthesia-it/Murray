import UIKit
import Boomerang
import RxSwift
import Action
import RxCocoa
import BonMot
import ModelLayer

enum TextStyles {
    case normal
    case email
    case euro
    case password
    case disabled
}
enum TextTheme {
    case light
    case dark
    
    var fontSize:CGFloat {
        switch self {
        case .light : return 16
        default : return 14
        }
    }
    
    var color : UIColor {
        switch self {
        case .light : return .white
        default : return UIColor.black
        }
    }
    var labelColor : UIColor {
        switch self {
        case .light : return .white
        default : return UIColor.black
        }
    }
}

class TextStyle: FormStyle {
    var style: TextStyles = .normal
    var theme:TextTheme = .dark
    init (_ style: TextStyles, theme:TextTheme = .dark) {
        self.style = style
        self.theme = theme
    }
    var isEnabled: Bool {
        switch self.style {
        case .disabled : return false
        default : return true
        }
    }
    var isSecure: Bool {
        switch self.style {
        case .password : return true
        default : return false
        }
    }
    var keyboard: UIKeyboardType {
        switch self.style {
        case .email : return .emailAddress
        case .euro : return .decimalPad
        default : return .default
        }
    }
}

class TextItemView: UIView, ViewModelBindable, EmbeddableView {

    @IBOutlet var textField: UITextField!
    @IBOutlet var titleLabel: UILabel!
    var button = UIButton()
    var viewModel: ItemViewModelType?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func bind(to viewModel: ViewModelType?) {

        self.viewModel = viewModel as? ItemViewModelType
        self.disposeBag = DisposeBag()
        self.textField.textColor = UIColor.white
        if self.isPlaceholder { return }
        button.removeFromSuperview()
        
        switch viewModel {

        case let viewModel as ListPickerItemViewModelType :
            button.removeFromSuperview()
            button.rx.unbindAction()
            
            self.textField.rightView = UIImageView(image: UIImage(named:"ic_dropdown_arrow"))
            self.textField.rightViewMode = .always
            self.titleLabel.textColor = TextTheme.dark.labelColor
            self.titleLabel.text = viewModel.title
            let theme = TextTheme.dark
            self.textField.tintColor = theme.color
             self.textField.attributedPlaceholder = StringStyle(.font(textField.font ?? .systemFont(ofSize: 10)),.color(theme.color.withAlphaComponent(0.3))).attributedString(from: viewModel.title)
            self.textField.textColor = TextTheme.dark.color
            self.textField.font = UIFont.type(type: .roboto, weight: .regular, size: TextTheme.dark.fontSize)
            self.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            
            viewModel.enabledIf.subscribe(onNext: {[weak self] in
                $0 == true ? self?.button.rx.bind(to: viewModel.selection, input: .openPicker) : self?.button.rx.unbindAction()
                }).disposed(by:disposeBag)
            viewModel.currentSelectedTitle.bind(to: textField.rx.text).disposed(by: disposeBag)

        case let viewModel as StringPickerItemViewModel :
           
            self.titleLabel.text = viewModel.title

            if self.isPlaceholder { return }
            
            let style = viewModel.style
            self.textField.font = UIFont.type(type: .roboto, weight: .regular, size: style.theme.fontSize)
            self.textField.attributedPlaceholder = StringStyle(.font(textField.font ?? .systemFont(ofSize: 10)),.color(style.theme.color.withAlphaComponent(0.3))).attributedString(from: viewModel.title)
      
            self.titleLabel.textColor = style.theme.labelColor
            
            self.textField.isEnabled = style.isEnabled
            self.textField.isSecureTextEntry = style.isSecure
            self.textField.keyboardType = style.keyboard
            self.textField.textColor = style.theme.color
            
            let clearButton = UIButton()
            clearButton.setImage(UIImage(named:"ic_cancel")?.tinted(style.theme.color), for: .normal)
            clearButton.rx.tap.subscribe(onNext: {[weak self] _ in self?.textField.text = ""}).disposed(by:disposeBag)
            self.textField.rightView = clearButton
            self.textField.rightViewMode = .whileEditing
            self.textField.tintColor = style.theme.color
            viewModel.enabledIf.bind(to: self.textField.rx.isEnabled).disposed(by: disposeBag)
            //            Observable.combineLatest(viewModel.value.asObservable().map {$0.count > 0},viewModel.error) {
            //                return $0 || $1 != nil
            //                }
            //                .map{!$0}.bind(to: self.titleLabel.rx.isHidden).disposed(by:disposeBag)
            (textField.rx.textInput <-> viewModel.value ).disposed(by: disposeBag)

            viewModel.error.map { $0 != nil ? UIColor.red : style.theme.labelColor }.subscribe(onNext: {
                [weak self] in self?.titleLabel.textColor = $0
            }).disposed(by: disposeBag)

            viewModel.error
                .map {
                    ($0 as? APPError)?.title ?? viewModel.title
                }.startWith(viewModel.title)
                .asDriver(onErrorJustReturn: viewModel.title)
                .drive(self.titleLabel.rx.text)
                .disposed(by: disposeBag)
            self.button.removeFromSuperview()
            self.button.rx.unbindAction()
            if viewModel.isFullscreen, let selection = viewModel.externalSelection {
                self.addSubview(self.button)
                self.button.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                viewModel.enabledIf.subscribe(onNext: {[weak self] in
                    $0 ? self?.button.rx.bind(to: selection, input: .viewModel(viewModel)) : self?.button.rx.unbindAction()
                }).disposed(by: disposeBag)
            }

        default : return
        }

    }
}
