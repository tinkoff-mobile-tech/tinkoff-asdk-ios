//
//
//  PullableContainerView.swift
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

final class PullableContainerView: PassthroughView {
    // MARK: Subviews

    let headerView = PullableContainerHeader()
    let dragView = UIView()
    let containerView = UIView()
    let contentView: UIView

    // MARK: Constraints

    private(set) var containerViewHeightConstraint: NSLayoutConstraint!
    private(set) var dragViewHeightConstraint: NSLayoutConstraint!

    // MARK: Init

    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setting Up

private extension PullableContainerView {
    func setup() {
        addSubview(dragView)
        dragView.addSubview(headerView)
        dragView.addSubview(containerView)

        setupHeaderView()
        setupDragView()
        setupContentView()
        setupConstraints()
    }

    func setupHeaderView() {
        headerView.isUserInteractionEnabled = false
    }

    func setupDragView() {
        dragView.backgroundColor = ASDKColors.Background.elevation1.color
        dragView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dragView.layer.cornerRadius = .cornerRadius
        dragView.layer.masksToBounds = true
    }

    func setupContentView() {
        containerView.addSubview(contentView)
    }

    func setupConstraints() {
        dragView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false

        dragViewHeightConstraint = dragView.heightAnchor.constraint(equalToConstant: 0)
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            dragView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dragView.leftAnchor.constraint(equalTo: leftAnchor),
            dragView.rightAnchor.constraint(equalTo: rightAnchor),
            dragViewHeightConstraint,

            headerView.topAnchor.constraint(equalTo: dragView.topAnchor),
            headerView.leftAnchor.constraint(equalTo: dragView.leftAnchor),
            headerView.rightAnchor.constraint(equalTo: dragView.rightAnchor),
            headerView.heightAnchor.constraint(equalToConstant: .topViewHeight),

            containerView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            containerView.leftAnchor.constraint(equalTo: dragView.leftAnchor),
            containerView.rightAnchor.constraint(equalTo: dragView.rightAnchor),
            containerViewHeightConstraint,
        ])

        contentView.pinEdgesToSuperview()
    }
}

// MARK: - Constants

private extension CGFloat {
    static let topViewHeight: CGFloat = 24
    static let cornerRadius: CGFloat = 16
}
