import UIKit

enum FontWeight {
    case regular
    case italic
    case bold
}

enum FontType {
    //customize fonts, these won't work out of the box
    case roboto
    case lato
    
    fileprivate func font(weight: FontWeight, size: CGFloat) -> UIFont {
        let fontName: String
        switch self {
        case .roboto :
            switch weight {
            case .italic: fontName = "Roboto"
            case .bold: fontName = "Roboto"
            case .regular: fontName = "Roboto"
            }
        case .lato :
            switch weight {
            case .italic: fontName = "Lato"
            case .regular: fontName = "Lato"
            case .bold: fontName = "Lato"
            }
        }
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size)
    }
}

extension UIFont {
    static func type(type: FontType, weight: FontWeight, size: CGFloat) -> UIFont {
        return type.font(weight: weight, size: size)
    }
}
