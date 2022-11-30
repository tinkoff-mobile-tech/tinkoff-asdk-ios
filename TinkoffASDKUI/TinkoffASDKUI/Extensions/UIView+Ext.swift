//
//  UIView+Ext.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 27.10.2022.
//

import UIKit

// MARK: - UIView + Constraints

extension UIView {

    var forcedSuperview: UIView { superview! }

    func height(constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .height,
            multiplier: 1,
            constant: constant
        )
    }

    func width(constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .width,
            multiplier: 1,
            constant: constant
        )
    }

    func size(_ size: CGSize) -> [NSLayoutConstraint] {
        [
            height(constant: size.height),
            width(constant: size.width),
        ]
    }

    func makeLeftAndRightEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint] {
        return [
            leftAnchor.constraint(equalTo: forcedSuperview.leftAnchor, constant: inset),
            rightAnchor.constraint(equalTo: forcedSuperview.rightAnchor, constant: inset),
        ]
    }

    func makeTopAndBottomEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint] {
        assert(superview != nil)
        return [
            topAnchor.constraint(equalTo: forcedSuperview.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: forcedSuperview.bottomAnchor, constant: inset),
        ]
    }

    func makeConstraints(_ closure: (_ view: UIView) -> [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(closure(self))
    }

    func makeEqualToSuperview(insets: UIEdgeInsets = .zero) {
        assert(superview != nil)
        makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: forcedSuperview.topAnchor, constant: insets.top),
                make.leftAnchor.constraint(equalTo: forcedSuperview.leftAnchor, constant: insets.left),
                make.rightAnchor.constraint(equalTo: forcedSuperview.rightAnchor, constant: -insets.right),
                make.bottomAnchor.constraint(equalTo: forcedSuperview.bottomAnchor, constant: -insets.bottom),
            ]
        }
    }

    func makeCenterEqualToSuperview(xOffset: CGFloat = .zero, yOffset: CGFloat = .zero) -> [NSLayoutConstraint] {
        assert(superview != nil)
        return [
            centerXAnchor.constraint(equalTo: forcedSuperview.centerXAnchor, constant: xOffset),
            centerYAnchor.constraint(equalTo: forcedSuperview.centerYAnchor, constant: yOffset),
        ]
    }

    func makeEqualToSuperviewToSafeArea(insets: UIEdgeInsets = .zero) {
        assert(superview != nil)
        makeConstraints { make in
            [
                make.topAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
                make.leftAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.leftAnchor, constant: insets.left),
                make.rightAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.rightAnchor, constant: -insets.right),
                make.bottomAnchor.constraint(equalTo: forcedSuperview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom),
            ]
        }
    }
}
