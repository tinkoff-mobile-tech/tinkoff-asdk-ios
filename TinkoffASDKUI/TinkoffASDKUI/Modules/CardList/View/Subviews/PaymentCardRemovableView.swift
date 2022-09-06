//
//
//  PaymentCardRemovableView.swift
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

final class PaymentCardRemovableView: UIView {
    // MARK: Action Handlers

    private var removeHandler: (() -> Void)?

    // MARK: Subviews

    private lazy var paymentCardView = PaymentCardView()

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            .cross.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = .asdk.dynamic.text.tertiary
        button.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
        return button
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
        let stack = UIStackView(arrangedSubviews: [paymentCardView, removeButton])
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .leadingInset),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            removeButton.widthAnchor.constraint(equalToConstant: .removeButtonWidth)
        ])
    }

    // MARK: Actions

    @objc private func removeTapped() {
        removeHandler?()
    }
}

// MARK: - Configurable

extension PaymentCardRemovableView: Configurable {
    struct Configuration {
        let pan: String
        let validThru: String
        let icon: UIImage?
        let removeHandler: () -> Void
    }

    func update(with configuration: Configuration) {
        removeHandler = configuration.removeHandler
        paymentCardView.update(with: configuration.paymentCardConfiguration)
    }
}

// MARK: - Reusable

extension PaymentCardRemovableView: Reusable {
    func prepareForReuse() {
        removeHandler = nil
        paymentCardView.prepareForReuse()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let leadingInset: CGFloat = 16
    static let removeButtonWidth: CGFloat = 48
}

private extension UIImage {
    static let cross: UIImage = Asset.tuiIcServiceCross24.image
}

// MARK: - Configuration Mapping

private extension PaymentCardRemovableView.Configuration {
    var paymentCardConfiguration: PaymentCardView.Configuration {
        PaymentCardView.Configuration(
            pan: pan,
            validThru: validThru,
            icon: icon
        )
    }
}

