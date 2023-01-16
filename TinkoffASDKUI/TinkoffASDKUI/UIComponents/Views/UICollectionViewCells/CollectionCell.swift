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
            guard shouldHighlight else { return }
            apply(highlighted: isHighlighted)
        }
    }

    // MARK: Subviews

    lazy var content = Content()
    private lazy var background = UIView()

    // MARK: Settable

    private var shouldHighlight = true

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
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
        contentView.addSubview(content)
        background.pinEdgesToSuperview()
        content.makeEqualToSuperview()
    }

    // MARK: State Updating

    private func apply(highlighted: Bool) {
        UIView.transition(
            with: self,
            duration: .highlightAnimationDuration,
            options: .transitionCrossDissolve
        ) { [self] in
            background.backgroundColor = highlighted
                ? ASDKColors.Background.highlight.color
                : .clear
        }
    }
}

// MARK: - Configurable

extension CollectionCell: Configurable {
    typealias ContentConfiguration = Content.Configuration

    struct Configuration {
        let contentConfiguration: Content.Configuration
        var shouldHighlight = true
    }

    func update(with configuration: Configuration) {
        shouldHighlight = configuration.shouldHighlight
        content.update(with: configuration.contentConfiguration)
    }
}

// MARK: - Constants

extension TimeInterval {
    static let highlightAnimationDuration: TimeInterval = 0.15
}
