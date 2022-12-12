//
//  UIView+Animate.swift
//  popup
//
//  Created by Ivan Glushko on 23.11.2022.
//

import UIKit

extension UIView {

    static func animate(
        withDuration duration: TimeInterval,
        curve: CAMediaTimingFunction,
        delay: TimeInterval,
        usingSpringWithDamping dampingRatio: CGFloat,
        initialSpringVelocity velocity: CGFloat,
        options: UIView.AnimationOptions = [],
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(curve)
        UIView.animate(
            withDuration: duration,
            delay: delay,
            usingSpringWithDamping: dampingRatio,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: completion
        )
        CATransaction.commit()
    }

    func setAnchorPoint(_ point: CGPoint) {
        var newPoint = CGPoint(x: bounds.size.width * point.x, y: bounds.size.height * point.y)
        var oldPoint = CGPoint(x: bounds.size.width * layer.anchorPoint.x, y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = point
    }
}

extension UIView {

    final class Animation {
        var isAnimating: Bool
        let body: () -> Void
        let completion: (Bool) -> Void

        init(
            isAnimating: Bool = false,
            body: @escaping () -> Void,
            completion: @escaping (Bool) -> Void
        ) {
            self.isAnimating = isAnimating
            self.body = body
            self.completion = completion
        }

        convenience init() {
            self.init(body: {}, completion: { _ in })
        }
    }
}
