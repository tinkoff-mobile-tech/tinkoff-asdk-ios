//
//
//  HorizontalTitleSwitchView.swift
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

extension HorizontalTitleSwitchView {

    struct Model {
        let isOn: Bool
        let isEnabled: Bool
        let text: String
        let onSwitch: (Bool) -> Void
    }

    struct Style {
        static let basic = Style()
        var spacingBetween: CGFloat = 15
    }
}

final class HorizontalTitleSwitchView: UIView, ConfigurableAndReusable, Stylable {

    // ui
    private let label = UILabel()
    private let switchView = UISwitch()

    // state
    private var spacingBetween: CGFloat = 0
    private var onSwitch: (Bool) -> Void = { _ in }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: label.intrinsicContentSize.width
                + spacingBetween
                + switchView.intrinsicContentSize.width,
            height: max(
                label.intrinsicContentSize.height,
                switchView.intrinsicContentSize.height
            )
        )
    }

    private func setupViews() {
        addSubview(label)
        addSubview(switchView)

        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    @objc private func switched() {
        onSwitch(switchView.isOn)
    }

    func setSwitchingEnabled(to value: Bool) {
        switchView.isEnabled = value
    }

    func configure(model: Model) {
        onSwitch = model.onSwitch
        label.text = model.text
        switchView.isOn = model.isOn
        switchView.isEnabled = model.isEnabled
        switchView.addTarget(self, action: #selector(switched), for: .valueChanged)
    }

    func apply(style: Style) {
        setupViews()
        spacingBetween = style.spacingBetween

        switchView.dsl.makeConstraints { make in
            [
                make.right.constraint(equalTo: make.superview.rightAnchor),
                make.centerY.constraint(equalTo: make.superview.centerYAnchor),
            ]
        }

        label.dsl.makeConstraints { make in
            [
                make.left.constraint(equalTo: make.superview.leftAnchor),
                make.right.constraint(lessThanOrEqualTo: switchView.dsl.left, constant: -spacingBetween),
                make.top.constraint(equalTo: make.superview.topAnchor),
                make.bottom.constraint(equalTo: make.superview.bottomAnchor),
            ]
        }
    }

    func prepareForReuse() {
        label.text = nil
        switchView.isOn = false
        onSwitch = { _ in }
    }
}
