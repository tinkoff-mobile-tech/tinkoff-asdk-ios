//
//  UIView+Animate.swift
//  popup
//
//  Created by Ivan Glushko on 23.11.2022.
//

import UIKit

extension UIView {

    /// Анимированно показывает вьюху
    /// - Parameters:
    ///   - view: Вьюха которую надо показать
    ///   - duration: Продолжительность анимации, если не указывать, будет применена дефолтная продолжительность
    static func animateShow(view: UIView, duration: TimeInterval = .defaultAnimationDuration) {
        UIView.animate(withDuration: duration) {
            view.alpha = 1.0
        }
    }

    /// Анимированно добавляет вьюху на супервью
    /// - Parameters:
    ///   - subview: Вьюха которая будет добавлена
    ///   - parent: Вьюха на которую будет добавляться subview
    ///   - duration: Продолжительность анимации, если не указывать, будет применена дефолтная продолжительность
    static func animateAddSubview(_ subview: UIView, at parent: UIView, duration: TimeInterval = .defaultAnimationDuration) {
        subview.alpha = 0.0
        parent.addSubview(subview)

        UIView.animate(withDuration: duration) {
            subview.alpha = 1.0
        }
    }

    /// Анимированно удаляет вьюху с супервью
    /// - Parameters:
    ///   - view: Вьюха которую надо удалить
    ///   - duration: Продолжительность анимации, если не указывать, будет применена дефолтная продолжительность
    static func animateRemoveFromSuperview(for view: UIView, duration: TimeInterval = .defaultAnimationDuration) {
        UIView.animate(withDuration: duration, animations: {
            view.alpha = 0.0
        }, completion: { _ in
            view.removeFromSuperview()
        })
    }

    static func addPopingAnimation(
        animations: @escaping () -> Void,
        completion: ((Bool) -> Void)? = nil
    ) {
        Self.animate(
            withDuration: 0.2,
            delay: .zero,
            options: .transitionCrossDissolve,
            animations: animations,
            completion: completion
        )
    }

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
