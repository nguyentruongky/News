//  Created by Ky Nguyen

import UIKit

struct Messenger {
    static func getMessage(_ message: String?, title: String?,
                           cancelActionName: String? = "OK") -> UIAlertController {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if cancelActionName != nil {
            vc.addAction(UIAlertAction(title: cancelActionName, style: .destructive, handler: nil))
        }
        return vc
    }
    
    static func showMessage(_ message: String?, title: String?,
                           cancelActionName: String? = "OK") {
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if cancelActionName != nil {
            vc.addAction(UIAlertAction(title: cancelActionName, style: .destructive, handler: nil))
        }
        
        UIApplication.topViewController()?.present(vc)
    }
}

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

extension UIViewController {
    func present(_ controller: UIViewController) {
        present(controller, animated: true)
    }
}
