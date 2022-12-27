//
//  UILabel+Configuration.swift
//  popup
//
//  Created by Ivan Glushko on 21.11.2022.
//

import UIKit

extension UILabel {
    convenience init(style: Style) {
        self.init(frame: .zero)
        apply(style: style)
    }

    func configure(_ configuration: Configuration) {
        prepareForReuse()
        apply(data: configuration.data)
        apply(style: configuration.style)
    }

    func prepareForReuse() {
        text = nil
        textColor = .black
        font = .systemFont(ofSize: 16)
        textAlignment = .left
        numberOfLines = 0
    }

    private func apply(style: Style) {
        textColor = style.textColor
        font = style.font
        textAlignment = style.alignment
        numberOfLines = style.numberOfLines
    }

    private func apply(data: Data) {
        text = data.text
    }
}

extension UILabel {

    struct Configuration {
        let data: Data
        var style: Style
    }

    struct Data {
        let text: String?
    }

    struct Style {
        var textColor: UIColor? = .black
        var font: UIFont? = .systemFont(ofSize: 16, weight: .regular)
        var alignment: NSTextAlignment = .left
        var numberOfLines = 0 // no limit

        func set(alignment: NSTextAlignment) -> Style {
            var style = self
            style.alignment = alignment
            return style
        }

        func set(textColor: UIColor?) -> Style {
            var style = self
            style.textColor = textColor
            return style
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

    static var bodyL: Self {
        Self(
            textColor: ASDKColors.Text.primary.color,
            font: .systemFont(ofSize: 17, weight: .regular)
        )
    }

    static let bodyM = Self(
        textColor: ASDKColors.Text.primary.color,
        font: .systemFont(ofSize: 15, weight: .regular),
        alignment: .left,
        numberOfLines: 0
    )
}
