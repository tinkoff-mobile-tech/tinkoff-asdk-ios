//
//
//  ASDKButton.swift
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

final class ASDKButton: UIButton {
    // MARK: Style

    struct Style {
        struct Border {
            let cornerRadius: CGFloat
            let width: CGFloat
            let color: UIColor

            init(
                cornerRadius: CGFloat = .zero,
                width: CGFloat = .zero,
                color: UIColor = .clear
            ) {
                self.cornerRadius = cornerRadius
                self.width = width
                self.color = color
            }
        }

        struct Title {
            let text: String
            let color: UIColor
            let font: UIFont
            let transform: CGAffineTransform

            init(
                text: String,
                color: UIColor = .asdk.textPrimary,
                font: UIFont = .systemFont(ofSize: 15, weight: .regular),
                transform: CGAffineTransform = .identity
            ) {
                self.text = text
                self.color = color
                self.font = font
                self.transform = transform
            }
        }

        struct Icon {
            let image: UIImage?
            let transform: CGAffineTransform

            init(image: UIImage? = nil, transform: CGAffineTransform = .identity) {
                self.image = image
                self.transform = transform
            }
        }

        struct IntrinsicSize {
            let height: CGFloat?
            let width: CGFloat?

            init(height: CGFloat? = nil, width: CGFloat? = nil) {
                self.height = height
                self.width = width
            }
        }

        let title: Title
        let icon: Icon?
        let border: Border
        let size: IntrinsicSize?
        let backgroundColor: UIColor
        let transform: CGAffineTransform

        init(
            title: Title,
            icon: Icon? = nil,
            border: Border = Border(),
            size: IntrinsicSize? = nil,
            backgroundColor: UIColor,
            transform: CGAffineTransform = .identity
        ) {
            self.title = title
            self.icon = icon
            self.border = border
            self.size = size
            self.backgroundColor = backgroundColor
            self.transform = transform
        }
    }

    // MARK: Parents Properties

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        style.size?.height.map { size.height = $0 }
        style.size?.width.map { size.width = $0 }
        return size
    }

    // MARK: Properties

    private let style: Style

    // MARK: Init

    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Parent Methods

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateBorderColors()
    }

    // MARK: Initial Configuration

    private func setup() {
        setTitle(style.title.text, for: .normal)
        setTitleColor(style.title.color, for: .normal)
        setTitleColor(style.title.color.withAlphaComponent(.alphaComponent), for: .disabled)
        setTitleColor(style.title.color.withAlphaComponent(.alphaComponent), for: .highlighted)
        titleLabel?.font = style.title.font
        titleLabel?.transform = style.title.transform

        setImage(style.icon?.image, for: .normal)
        imageView?.transform = style.icon?.transform ?? .identity

        layer.cornerRadius = style.border.cornerRadius
        layer.borderWidth = style.border.width
        updateBorderColors()

        backgroundColor = style.backgroundColor
        transform = style.transform
    }

    private func updateBorderColors() {
        layer.borderColor = style.border.color.cgColor
    }
}

private extension CGFloat {
    static let alphaComponent: CGFloat = 0.4
}
