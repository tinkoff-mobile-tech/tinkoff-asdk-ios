//
//
//  CollectionCell.swift
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


import Foundation
import UIKit

final class CollectionCell<Content: UIView & Reusable & Configurable>: UICollectionViewCell {
    // MARK: Parent Property Observers

    override var isHighlighted: Bool {
        didSet {
            apply(highlighted: isHighlighted)
        }
    }

    // MARK: Subviews

    private lazy var content = Content()
    private lazy var background = UIView()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Parent Methods

    override func prepareForReuse() {
        super.prepareForReuse()
        content.prepareForReuse()
    }

    // MARK: Initial Configuration

    private func setupView() {
        contentView.addSubview(background)
        background.pinEdgesToSuperview()
        contentView.addSubview(content)
        content.pinEdgesToSuperview()
    }

    // MARK: State Updating

    private func apply(highlighted: Bool) {
        UIView.transition(
            with: self,
            duration: .highlightAnimationDuration,
            options: .transitionCrossDissolve
        ) { [self] in
            background.backgroundColor = highlighted
            ? .asdk.dynamic.background.highlight
            : .clear
        }
    }
}

// MARK: - Configurable

extension CollectionCell: Configurable {
    typealias Configuration = Content.Configuration

    func update(with configuration: Configuration) {
        content.update(with: configuration)
    }
}

// MARK: - Constants

private extension TimeInterval {
    static let highlightAnimationDuration: TimeInterval = 0.15
}
