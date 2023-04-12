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

    private(set) lazy var dragView: UIView = {
        let dragView = UIView()
        dragView.backgroundColor = ASDKColors.Background.elevation1.color
        dragView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        dragView.layer.cornerRadius = .cornerRadius
        dragView.layer.masksToBounds = true
        return dragView
    }()

    private(set) lazy var headerView: UIView = {
        let headerView = PullableContainerHeader()
        headerView.isUserInteractionEnabled = false
        return headerView
    }()

    // MARK: Constraints

    private(set) lazy var dragViewHeightConstraint = dragView.heightAnchor.constraint(equalToConstant: .zero)

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: PullableContainerView

    func add(contentView: UIView) {
        dragView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: dragView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: dragView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: dragView.bottomAnchor),
        ])
    }

    // MARK: Setting Up

    private func setup() {
        addSubview(dragView)
        dragView.addSubview(headerView)

        dragView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dragView.bottomAnchor.constraint(equalTo: bottomAnchor),
            dragView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dragView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dragViewHeightConstraint,

            headerView.topAnchor.constraint(equalTo: dragView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: dragView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: dragView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: .topViewHeight),
        ])
    }
}

// MARK: - Constants

private extension CGFloat {
    static let topViewHeight: CGFloat = 24
    static let cornerRadius: CGFloat = 16
}
