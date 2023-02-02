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
}
