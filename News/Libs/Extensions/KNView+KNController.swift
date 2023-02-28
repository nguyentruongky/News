//  Created by Ky Nguyen

import UIKit

class KNView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func setupView() { }
}

class KNController: UIViewController {
    var shouldGetDataViewDidLoad: Bool {
        return false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if shouldGetDataViewDidLoad {
            getData()
        }
        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func setupView() {}
    func getData() {}
    deinit {
        print("Deinit \(NSStringFromClass(type(of: self)))")
    }
}

extension UIView {
    func setBorder(width: CGFloat, color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    func setCorner(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }

}
