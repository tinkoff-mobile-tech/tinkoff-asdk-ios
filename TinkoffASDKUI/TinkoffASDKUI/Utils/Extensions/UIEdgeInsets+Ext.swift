import UIKit

extension UIEdgeInsets {

    var vertical: CGFloat { top + bottom }
    var horizontal: CGFloat { left + right }

    init(side: CGFloat) {
        self = Self(top: side, left: side, bottom: side, right: side)
    }

    init(vertical: CGFloat) {
        self = Self(top: vertical, left: .zero, bottom: vertical, right: .zero)
    }

    init(horizontal: CGFloat) {
        self = Self(top: .zero, left: horizontal, bottom: .zero, right: horizontal)
    }

    init(vertical: CGFloat, horizontal: CGFloat) {
        self = Self(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
}
