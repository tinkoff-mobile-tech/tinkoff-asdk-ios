//
//
//  ConstraintsDsl.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit

protocol ConstraintsDsl {
    var top: NSLayoutYAxisAnchor { get }
    var left: NSLayoutXAxisAnchor { get }
    var right: NSLayoutXAxisAnchor { get }
    var bottom: NSLayoutYAxisAnchor { get }
    var centerY: NSLayoutYAxisAnchor { get }
    var centerX: NSLayoutXAxisAnchor { get }

    var superview: UIView { get }

    func makeConstraints(_ closure: (_ make: ConstraintsDsl) -> [NSLayoutConstraint])
    func makeEqualToSuperview(insets: UIEdgeInsets)
    func makeEqualToSuperviewToSafeArea(insets: UIEdgeInsets)
    func makeLeftAndRightEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint]
    func makeTopAndBottomEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint]
    func size(_ size: CGSize) -> [NSLayoutConstraint]
    func width(constant: CGFloat) -> NSLayoutConstraint
    func height(constant: CGFloat) -> NSLayoutConstraint
}

extension ConstraintsDsl {
    func makeEqualToSuperview() {
        makeEqualToSuperview(insets: .zero)
    }

    func makeEqualToSuperviewToSafeArea() {
        makeEqualToSuperviewToSafeArea(insets: .zero)
    }
}

protocol ConstraintsDslAppliable {
    var dsl: ConstraintsDsl { get }
}

// MARK: - UIView + ConstraintsDslAppliable

extension UIView: ConstraintsDslAppliable {
    var dsl: ConstraintsDsl { DslWrapper(wrappedValue: self) }
}

struct DslWrapper<T> {
    var wrappedValue: T
}

// MARK: - ConstraintsDsl + ConstraintsDsl<UIView>

extension DslWrapper: ConstraintsDsl where T: UIView {
    var top: NSLayoutYAxisAnchor { wrappedValue.topAnchor }
    var left: NSLayoutXAxisAnchor { wrappedValue.leftAnchor }
    var right: NSLayoutXAxisAnchor { wrappedValue.rightAnchor }
    var bottom: NSLayoutYAxisAnchor { wrappedValue.bottomAnchor }
    var centerY: NSLayoutYAxisAnchor { wrappedValue.centerYAnchor }
    var centerX: NSLayoutXAxisAnchor { wrappedValue.centerXAnchor }

    var superview: UIView { wrappedValue.superview! }

    func height(constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: wrappedValue,
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
            item: wrappedValue,
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
            left.constraint(equalTo: superview.leftAnchor, constant: inset),
            right.constraint(equalTo: superview.rightAnchor, constant: inset),
        ]
    }

    func makeTopAndBottomEqualToSuperView(inset: CGFloat) -> [NSLayoutConstraint] {
        assert(wrappedValue.superview != nil)
        guard let superview = wrappedValue.superview else { return [] }
        return [
            top.constraint(equalTo: superview.dsl.top, constant: inset),
            bottom.constraint(equalTo: superview.dsl.bottom, constant: inset),
        ]
    }

    func makeConstraints(_ closure: (_ make: ConstraintsDsl) -> [NSLayoutConstraint]) {
        wrappedValue.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(closure(self))
    }

    func makeEqualToSuperview(insets: UIEdgeInsets) {
        assert(wrappedValue.superview != nil)
        guard let superview = wrappedValue.superview else { return }
        makeConstraints { make in
            [
                make.top.constraint(equalTo: superview.dsl.top, constant: insets.top),
                make.left.constraint(equalTo: superview.dsl.left, constant: insets.left),
                make.right.constraint(equalTo: superview.dsl.right, constant: -insets.right),
                make.bottom.constraint(equalTo: superview.dsl.bottom, constant: -insets.bottom),
            ]
        }
    }

    func makeEqualToSuperviewToSafeArea(insets: UIEdgeInsets) {
        assert(wrappedValue.superview != nil)
        guard let superview = wrappedValue.superview else { return }
        makeConstraints { make in
            [
                make.top.constraint(equalTo: superview.safeAreaLayoutGuide.topAnchor, constant: insets.top),
                make.left.constraint(equalTo: superview.safeAreaLayoutGuide.leftAnchor, constant: insets.left),
                make.right.constraint(equalTo: superview.safeAreaLayoutGuide.rightAnchor, constant: -insets.right),
                make.bottom.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom),
            ]
        }
    }
}
