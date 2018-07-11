import UIKit

enum SeparatorPosition {
    case Top
    case Bottom
}
class SeparatorAttributes : UICollectionViewLayoutAttributes {
    var backgroundColor:UIColor! = UIColor.gray
}
class SeparatorView : UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        self.backgroundColor = (layoutAttributes as? SeparatorAttributes)?.backgroundColor ?? .white
    }
}

class SeparatorLayout : UICollectionViewFlowLayout {
    var nibName:String = "DecorationView"
    var separatorPosition:SeparatorPosition! = .Bottom
    var separatorIndexPaths:[NSIndexPath]?
    var separatorColor : UIColor! = .red
    var height : CGFloat = 15
    var sidePadding : CGFloat = 15
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//         // <---
        self.commonInit()
//        self.register(SeparatorView.self, forDecorationViewOfKind: "NewsDecorationView") // <---
        
    }
    override init() {
        super.init()
        self.commonInit()
    }
    func commonInit() {
        let name = self.nibName
        self.register(UINib(nibName:name, bundle: nil ), forDecorationViewOfKind: name)
       // self.register(SeparatorView.self, forDecorationViewOfKind: "SeparatorView")
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        
        let newAttributes = attributes!.filter({[weak self] (attribute:UICollectionViewLayoutAttributes) -> Bool in
            var contained = true
            if (attribute.representedElementCategory != UICollectionElementCategory.cell) {
                return false
            }
            if (self?.separatorIndexPaths != nil) {
                contained = self!.separatorIndexPaths!.contains(attribute.indexPath as NSIndexPath)
            }
            let n = (self?.collectionView?.numberOfItems(inSection: attribute.indexPath.section) ?? 0)
            if (self?.separatorPosition == .Bottom) {
                return  attribute.indexPath.item <  n - 1 && n > 1 && contained
            } else {
                return contained
            }
            }).map({[weak self] (attribute:UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes in
                let separator = SeparatorAttributes(forDecorationViewOfKind: self?.nibName ?? "", with: attribute.indexPath)
                var frame = CGRect()
                let x:CGFloat = 0
                let w = attribute.frame.size.width
                let h = self?.height ?? 1
                if (self?.separatorPosition == .Bottom) {
                    frame = CGRect(x:x, y:attribute.frame.origin.y + attribute.frame.size.height-1 + (self?.minimumLineSpacing ?? 0)/2.0 ,width: w, height: h)
                } else {
                    frame = CGRect(x:x, y:attribute.frame.origin.y - (self?.minimumLineSpacing ?? 0)/2.0 , width: w, height: h)
                }
                separator.frame = frame
                separator.zIndex = 100
                separator.backgroundColor = self?.separatorColor
                return separator
            })
        
        attributes!.append(contentsOf: newAttributes)

        return attributes
    }
    
}
