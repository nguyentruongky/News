//  Created by Ky Nguyen

import UIKit

extension UIWindow {
    class func keyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.filter({$0.activationState == .foregroundActive}).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
        } else {
            return UIApplication.shared.keyWindow!
        }
    }
}

extension UIApplication {
    class func present(_ controller: UIViewController) {
        let topController = topViewController()
        topController?.present(controller, animated: true)
    }

    class func topViewController(controller: UIViewController? = UIWindow.keyWindow()?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }

}
