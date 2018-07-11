import Foundation
import RxSwift
import Boomerang

private struct AssociatedKeys {
    static var disposeBag = "disposeBag"
}
extension UIView {

    public var disposeBag: DisposeBag {
        get {
            var disposeBag: DisposeBag
            
            if let lookup = objc_getAssociatedObject(self, &AssociatedKeys.disposeBag) as? DisposeBag {
                disposeBag = lookup
            } else {
                disposeBag = DisposeBag()
                objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, disposeBag, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            return disposeBag
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.disposeBag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

extension UIView {
    func findFirstResponder() -> UIView? {
        if (self.isFirstResponder) {
            return self
        }
        if (self.subviews.count == 0) {
            return nil
        }
        return self.subviews.map {$0.findFirstResponder() ?? self}.filter {$0 != self}.first
    }
}
