//
//
//  MessageView.swift
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

final class MessageView: UIView {
    // MARK: Style

    struct Style {
        let largeImage: UIImage?
        let message: String
    }

    // MARK: Dependencies

    private let style: Style

    // MARK: Subviews

    private lazy var largeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = style.largeImage
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ASDKColors.Text.primary.color
        label.text = style.message
        return label
    }()

    // MARK: Init

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Initial Configuration

    private func setupView() {
        let stack = UIStackView(arrangedSubviews: [largeImageView, messageLabel])
        stack.axis = .vertical
        stack.spacing = .contentSpacing

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .contentHorizontalInsets),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.contentHorizontalInsets),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -.contentSpacing),
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let contentSpacing: CGFloat = 24
    static let contentHorizontalInsets: CGFloat = 42
}
