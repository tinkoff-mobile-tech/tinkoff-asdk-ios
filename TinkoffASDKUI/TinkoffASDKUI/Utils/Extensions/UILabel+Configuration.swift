//
//  UILabel+Configuration.swift
//  popup
//
//  Created by Ivan Glushko on 21.11.2022.
//

import UIKit

extension UILabel {

    func configure(_ configuration: Configuration) {
        prepareForReuse()

        switch configuration.content {
        case let .plain(text, style):
            self.text = text
            textColor = style.textColor
            font = style.font
            textAlignment = style.alignment
            numberOfLines = style.numberOfLines
            lineBreakMode = style.lineBreakMode

        case let .attributed(string):
            attributedText = string
        }
    }

    func prepareForReuse() {
        text = nil
        attributedText = nil
        textColor = .black
        font = .systemFont(ofSize: 16)
        textAlignment = .left
        numberOfLines = 0
    }
}

extension UILabel {

    enum Content {
        case plain(text: String?, style: UILabel.Style)
        case attributed(string: NSAttributedString?)

        static var empty: Self { Self.attributed(string: nil) }

        var text: String {
            switch self {
            case let .plain(text, _):
                return text ?? ""
            case let .attributed(atrString):
                return atrString?.string ?? ""
            }
        }
    }

    struct Configuration {
        let content: Content

        static var empty: Self { Self(content: .empty) }
    }

    struct Style {
        var textColor: UIColor? = .black
        var font: UIFont = .systemFont(ofSize: 16, weight: .regular)
        var alignment: NSTextAlignment = .left
        var numberOfLines = 0 // no limit
        var lineBreakMode: NSLineBreakMode = .byClipping

        func set(textColor: UIColor?) -> Self {
            var shadowCopy = self
            shadowCopy.textColor = textColor
            return shadowCopy
        }

        func set(font: UIFont) -> Self {
            var shadowCopy = self
            shadowCopy.font = font
            return shadowCopy
        }

        func set(alignment: NSTextAlignment) -> Self {
            var shadowCopy = self
            shadowCopy.alignment = alignment
            return shadowCopy
        }

        func set(numberOfLines: Int) -> Self {
            var shadowCopy = self
            shadowCopy.numberOfLines = numberOfLines
            return shadowCopy
        }

        func set(lineBreakMode: NSLineBreakMode) -> Self {
            var shadowCopy = self
            shadowCopy.lineBreakMode = lineBreakMode
            return shadowCopy
        }
    }
}

// MARK: - Styles

extension UILabel.Style {
    static var headingM: Self {
        Self(
            textColor: ASDKColors.Text.primary.color,
            font: .systemFont(ofSize: 20, weight: .bold)
        )
    }

    static func bodyM() -> Self {
        Self(
            textColor: ASDKColors.Text.primary.color,
            font: .systemFont(ofSize: 15, weight: .regular),
            alignment: .left,
            numberOfLines: 0
        )
    }

    static func bodyL() -> Self {
        Self(
            textColor: ASDKColors.Text.primary.color,
            font: .systemFont(ofSize: 17, weight: .regular),
            alignment: .left,
            numberOfLines: 0
        )
    }

    static func headingS() -> Self {
        Self(
            textColor: ASDKColors.Text.primary.color,
            font: .systemFont(ofSize: 17, weight: .semibold),
            alignment: .left,
            numberOfLines: 0
        )
    }
}
