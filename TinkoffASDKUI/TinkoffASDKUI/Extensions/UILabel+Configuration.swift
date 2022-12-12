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
    }
}

// MARK: - Styles

extension UILabel.Style {

    static let bodyM = Self(
        textColor: ASDKColors.Text.primary.color,
        font: .systemFont(ofSize: 15, weight: .regular),
        alignment: .left,
        numberOfLines: 0
    )
}
