//
//
//  ContainerTableViewCell.swift
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

final class ContainerTableViewCell: UITableViewCell {
    private let containerView = UIView()
    private var cellContentView: UIView?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellContentView?.removeFromSuperview()
        cellContentView = nil
    }

    func setContent(_ contentView: UIView, insets: UIEdgeInsets = .zero) {
        cellContentView?.removeFromSuperview()
        cellContentView = contentView
        containerView.addSubview(contentView)
        contentView.makeEqualToSuperview(insets: insets)
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(containerView)
        containerView.makeEqualToSuperview()
    }
}

// MARK: - ReusableIdentifier

extension ContainerTableViewCell: ReusableIdentifier {}
