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

    typealias Cell = CollectionCell<PaymentCardRemovableView>

    override var intrinsicContentSize: CGSize { frame.size }

    // MARK: Action Handlers

    private var accessoryItemTap: (() -> Void)?

    // MARK: Subviews

    private let contentView = UIView()

    private lazy var cardView = DynamicIconCardView()
    private lazy var bankNameLabel = FadingLabel()
    private lazy var cardNumberLabel = UILabel()
    private let buttonContainer = ViewContainer()

    private lazy var acessoryRightButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    //

    private(set) var configuration: Configuration = .empty

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupViews() {
        addSubview(contentView)

        contentView.addSubview(cardView)
        contentView.addSubview(bankNameLabel)
        contentView.addSubview(cardNumberLabel)
        contentView.addSubview(buttonContainer)

        buttonContainer.clipsToBounds = true

        buttonContainer.configure(
            with: ViewContainer.Configuration(
                content: acessoryRightButton,
                layoutStrategy: .custom { $0.makeEqualToSuperview() }
            )
        )

        contentView.makeEqualToSuperview(insets: .zero)

        cardView.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor, constant: .cardViewTopInset),
                view.leftAnchor.constraint(equalTo: view.forcedSuperview.leftAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: view.forcedSuperview.bottomAnchor, constant: -.cardViewTopInset),
            ] + view.size(DynamicIconCardView.defaultSize)
        }

        bankNameLabel.makeConstraints { view in
            [
                view.leftAnchor.constraint(equalTo: cardView.rightAnchor, constant: .normalInset),
                view.rightAnchor.constraint(lessThanOrEqualTo: cardNumberLabel.leftAnchor),
                view.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            ]
        }

        cardNumberLabel.makeConstraints { view in
            [
                view.leftAnchor.constraint(equalTo: bankNameLabel.rightAnchor),
                view.rightAnchor.constraint(lessThanOrEqualTo: buttonContainer.leftAnchor),
                view.centerYAnchor.constraint(equalTo: bankNameLabel.centerYAnchor),
            ]
        }

        bankNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        bankNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        cardNumberLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        cardNumberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        buttonContainer.makeConstraints { view in
            [
                view.width(constant: .zero),
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor),
                view.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
                view.rightAnchor.constraint(equalTo: view.forcedSuperview.rightAnchor),
            ]
        }
    }

    private func configureAcessoryRightButton(item: AccessoryItem) {
        var isNoneCase = false
        if case AccessoryItem.none = item {
            isNoneCase = true
        }

        buttonContainer.isHidden = isNoneCase
        buttonContainer.constraintUpdater.updateWidth(to: isNoneCase ? .zero : .accessoryContainerWidth)

        switch item {
        case .none: break
        case .checkmark:
            acessoryRightButton.setImage(Asset.Icons.check.image.withRenderingMode(.alwaysTemplate), for: .normal)
            acessoryRightButton.tintColor = ASDKColors.Text.accent.color
            accessoryItemTap = nil
        case let .removeButton(removeAction):
            acessoryRightButton.setImage(Asset.tuiIcServiceCross24.image.withRenderingMode(.alwaysTemplate), for: .normal)
            acessoryRightButton.tintColor = ASDKColors.Text.secondary.color
            accessoryItemTap = removeAction
        }
    }

    // MARK: Actions

    @objc private func buttonTapped() {
        accessoryItemTap?()
    }
}

// MARK: - Configurable

extension PaymentCardRemovableView: ConfigurableItem, Configurable {

    enum AccessoryItem {
        case none
        case removeButton(onRemove: () -> Void)
        case checkmark
    }

    struct Configuration {
        let bankNameContent: UILabel.Content
        let cardNumberContent: UILabel.Content
        let card: DynamicIconCardView.Model
        let accessoryItem: AccessoryItem
        let insets: UIEdgeInsets
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        cardView.configure(model: configuration.card)
        bankNameLabel.configure(UILabel.Configuration(content: configuration.bankNameContent))
        cardNumberLabel.configure(UILabel.Configuration(content: configuration.cardNumberContent))
        contentView.constraintUpdater.updateEdgeInsets(insets: configuration.insets)
        configureAcessoryRightButton(item: configuration.accessoryItem)
    }

    func update(with configuration: Configuration) {
        configure(with: configuration)
    }
}

extension PaymentCardRemovableView.Configuration {

    static var empty: Self {
        Self(
            bankNameContent: .empty,
            cardNumberContent: .empty,
            card: DynamicIconCardView.Model(data: DynamicIconCardView.Data()),
            accessoryItem: .none,
            insets: .zero
        )
    }
}

// MARK: - Reusable

extension PaymentCardRemovableView: Reusable {
    func prepareForReuse() {
        accessoryItemTap = nil
        bankNameLabel.prepareForReuse()
        cardNumberLabel.prepareForReuse()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let normalInset: CGFloat = 16
    static let cardViewTopInset: CGFloat = 7
    static let accessoryContainerWidth: CGFloat = 48
}

extension PaymentCardRemovableView {
    static var contentInsets: UIEdgeInsets { UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 0) }
}
