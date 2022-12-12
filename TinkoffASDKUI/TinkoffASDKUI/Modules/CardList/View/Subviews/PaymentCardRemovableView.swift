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

    override var intrinsicContentSize: CGSize { frame.size }

    // MARK: Action Handlers

    private var removeHandler: (() -> Void)?

    // MARK: Subviews

    private let contentView = UIView()

    private lazy var cardView = DynamicIconCardView()
    private lazy var textLabel = UILabel()
    private let buttonContainer = ViewContainer()

    private lazy var removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            Asset.tuiIcServiceCross24.image.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = ASDKColors.Text.secondary.color
        button.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
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
        contentView.addSubview(textLabel)
        contentView.addSubview(buttonContainer)

        buttonContainer.clipsToBounds = true

        buttonContainer.configure(
            with: ViewContainer.Configuration(
                content: removeButton,
                layoutStrategy: .custom { view in
                    view.makeConstraints { view in
                        [
                            view.centerYAnchor.constraint(equalTo: view.forcedSuperview.centerYAnchor),
                            view.rightAnchor.constraint(equalTo: view.forcedSuperview.rightAnchor),
                        ]
                    }
                }
            )
        )

        contentView.makeEqualToSuperview(insets: .zero)

        cardView.makeConstraints { view in
            [
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor, constant: .cardViewTopInset),
                view.leftAnchor.constraint(equalTo: view.forcedSuperview.leftAnchor),
                view.bottomAnchor.constraint(lessThanOrEqualTo: view.forcedSuperview.bottomAnchor),
            ] + view.size(DynamicIconCardView.defaultSize)
        }

        textLabel.makeConstraints { view in
            [
                view.leftAnchor.constraint(equalTo: cardView.rightAnchor, constant: .normalInset),
                view.rightAnchor.constraint(equalTo: buttonContainer.leftAnchor),
                view.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            ]
        }

        buttonContainer.makeConstraints { view in
            [
                view.width(constant: .zero),
                view.topAnchor.constraint(equalTo: view.forcedSuperview.topAnchor),
                view.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
                view.rightAnchor.constraint(equalTo: view.forcedSuperview.rightAnchor),
            ]
        }
    }

    // MARK: Actions

    @objc private func removeTapped() {
        removeHandler?()
    }
}

// MARK: - Configurable

extension PaymentCardRemovableView: ConfigurableItem, Configurable {

    enum AccessoryItem {
        case none
        case removeButton(onRemove: () -> Void)
    }

    struct Configuration {
        let content: UILabel.Content
        let card: DynamicIconCardView.Model
        let accessoryItem: AccessoryItem
        let insets: UIEdgeInsets
    }

    func configure(with configuration: Configuration) {
        self.configuration = configuration
        cardView.configure(model: configuration.card)
        textLabel.configure(UILabel.Configuration(content: configuration.content))
        contentView.constraintUpdater.updateEdgeInsets(insets: configuration.insets)

        switch configuration.accessoryItem {
        case .none:
            buttonContainer.isHidden = true
            buttonContainer.constraintUpdater.updateWidth(to: .zero)
        case let .removeButton(onRemove):
            buttonContainer.isHidden = false
            buttonContainer.constraintUpdater.updateWidth(to: .accessoryContainerWidth)
            removeHandler = onRemove
        }
    }

    func update(with configuration: Configuration) {
        configure(with: configuration)
    }
}

extension PaymentCardRemovableView.Configuration {

    static var empty: Self {
        Self(
            content: .empty,
            card: DynamicIconCardView.Model(data: DynamicIconCardView.Data()),
            accessoryItem: .none,
            insets: .zero
        )
    }
}

// MARK: - Reusable

extension PaymentCardRemovableView: Reusable {
    func prepareForReuse() {
        cardView.clear()
        removeHandler = nil
        textLabel.prepareForReuse()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let removeButtonWidth: CGFloat = 48
    static let normalInset: CGFloat = 16
    static let cardViewTopInset: CGFloat = 7
    static let accessoryContainerWidth: CGFloat = 32
}

extension PaymentCardRemovableView {

    struct Constants {
        static var contentInsets: UIEdgeInsets {
            UIEdgeInsets(vertical: 8, horizontal: 16)
        }
    }
}
