//  Created by Ky Nguyen

import UIKit

extension UILabel {
    convenience init(text: String? = nil,
                     font: UIFont = .systemFont(ofSize: 15),
                     color: UIColor? = .black,
                     numberOfLines: Int = 1,
                     alignment: NSTextAlignment = .left) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        self.font = font
        textColor = color
        self.text = text
        self.numberOfLines = numberOfLines
        textAlignment = alignment
    }
}

extension UIView {
    convenience init(background: UIColor?) {
        self.init()
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = background
    }
}

extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis = .vertical,
                     distributon: UIStackView.Distribution = .equalSpacing,
                     alignment: UIStackView.Alignment = .center,
                     space: CGFloat = 16) {
        self.init()
        self.axis = axis
        self.distribution = distributon
        self.alignment = alignment
        self.spacing = space
        translatesAutoresizingMaskIntoConstraints = false
    }

    func clearView() {
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
