//
//
//  UIView+Ext.swift
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

// MARK: - UIView + Debug

extension UIView {

    func debug() {
        let colors: [UIColor] = [.red, .systemGreen, .blue]
        layer.borderWidth = 1
        layer.borderColor = (colors.randomElement() ?? .blue).cgColor
    }

    func debugRecursevly(view: UIView) {
        view.debug()

        for subview in view.subviews {
            subview.debug()
            debugRecursevly(view: subview)
        }
    }

    func debugRecursevly() {
        debugRecursevly(view: self)
    }
}

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
