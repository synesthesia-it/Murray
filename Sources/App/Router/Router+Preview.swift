import QuickLook
import Boomerang
extension QLPreviewController {
    private struct AssociatedKeys {
        static var previewer = "ql_previewer"
    }
   
    fileprivate var previewer:Previewer? {
        get { return objc_getAssociatedObject(self, &AssociatedKeys.previewer) as? Previewer}
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.previewer, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.dataSource = previewer
            self.delegate = previewer
        }

    }
}
final class Previewer : NSObject, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    var urls:[URL] = []
    convenience init(withFileURL url:URL) {
        self.init(withFileURLs:[url])
    }
    
    init(withFileURLs urls:[URL]) {
        super.init()
        self.urls = urls
    }
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return urls.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return urls[index] as QLPreviewItem
    }
}

extension Router {
    public static func preview<Source> (_ url:URL?, from source:Source) -> RouterAction where Source:UIViewController {
        guard let url = url else {return EmptyRouterAction()}        
        return Router.preview([url], from: source)
    }
    public static func preview<Source> (_ urls:[URL], from source:Source) -> RouterAction
        where Source: UIViewController {
            if (urls.count == 0) {return EmptyRouterAction()}
            
            let previewer = Previewer(withFileURLs: urls)
            let vc = QLPreviewController()
            
            vc.previewer = previewer
            return UIViewControllerRouterAction.modal(source: source, destination: vc, completion: nil)
    }
 
}
