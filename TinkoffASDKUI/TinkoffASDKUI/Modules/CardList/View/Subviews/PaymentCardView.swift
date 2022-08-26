//
//
//  PaymentCardView.swift
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

final class PaymentCardView: UIView {
    // MARK: Subviews

    private lazy var iconView: UIImageView = {
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()

    private lazy var panLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: .fontSize, weight: .regular)
        label.textColor = .asdk.dynamic.text.primary
        return label
    }()

    private lazy var validThruLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: .fontSize, weight: .regular)
        label.textColor = .asdk.dynamic.text.primary
        return label
    }()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        let labelsStack = UIStackView(arrangedSubviews: [panLabel, validThruLabel])
        labelsStack.axis = .horizontal
        labelsStack.distribution = .fillEqually
        labelsStack.spacing = .interItemSpacing

        let primaryStack = UIStackView(arrangedSubviews: [iconView, labelsStack])
        primaryStack.axis = .horizontal
        primaryStack.alignment = .center
        primaryStack.spacing = .interItemSpacing

        addSubview(primaryStack)
        primaryStack.pinEdgesToSuperview()

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: .iconSide),
            iconView.heightAnchor.constraint(equalToConstant: .iconSide)
        ])
    }
}

// MARK: - PaymentCardView + Configurable

extension PaymentCardView: Configurable {
    struct Configuration {
        let pan: String
        let validThru: String
        let icon: UIImage?
    }

    func update(with configuration: Configuration) {
        panLabel.text = configuration.pan
        validThruLabel.text = configuration.validThru
        iconView.image = configuration.icon
    }
}

// MARK: - PaymentCardView + Reusable

extension PaymentCardView: Reusable {
    func prepareForReuse() {
        panLabel.text = nil
        validThruLabel.text = nil
        iconView.image = nil
    }
}

// MARK: - CGFloat + Constants

private extension CGFloat {
    static let fontSize: CGFloat = 17
    static let iconSide: CGFloat = 40
    static let interItemSpacing: CGFloat = 16
}
