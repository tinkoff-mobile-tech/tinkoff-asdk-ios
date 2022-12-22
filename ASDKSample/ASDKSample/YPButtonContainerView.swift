//
//
//  YPButtonContainerView.swift
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

final class YPButtonContainerView: UIView {
    private let contentView = UIView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Updating

    func set(button: UIView) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        contentView.addSubview(button)
        button.makeEqualToSuperview()
    }

    // MARK: Initial Configuration

    private func setupView() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .horizontalInsets),
            contentView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -.horizontalInsets),
            contentView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: .verticalInsets),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -.verticalInsets),
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let horizontalInsets: CGFloat = 16
    static let verticalInsets: CGFloat = 8
}
