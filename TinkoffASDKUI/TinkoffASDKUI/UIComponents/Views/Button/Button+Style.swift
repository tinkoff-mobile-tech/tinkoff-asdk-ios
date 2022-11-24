//
//  Button+Styles.swift
//  ASDK
//
//  Created by Ivan Glushko on 15.11.2022.
//

import UIKit

extension Button {

    struct Style {
        enum Background {
            case color(normal: UIColor?, highlighted: UIColor?, disabled: UIColor?)
            case image(normal: UIImage?, highlighted: UIImage?, disabled: UIImage?)
        }

        let background: Background
        let cornerRadius: CGFloat
        let loaderStyle: ActivityIndicatorView.Style

        let basicTextStyle: Data.Text.Style?
    }
}

extension Button.Data.Text {

    struct Style {
        let normal: UIColor?
        let highlighted: UIColor?
        let disabled: UIColor?

        var font: UIFont? = .systemFont(ofSize: 16)
    }
}

// MARK: - Styles

extension Button.Style {

    // Primary

    static var primary: Self {
        Self(
            background: .color(
                normal: UIColor(hex: "#FEDE2E"),
                highlighted: UIColor(hex: "#FACE2E"),
                disabled: nil
            ),
            cornerRadius: .defaultCornerRadius,
            loaderStyle: ActivityIndicatorView.Style(
                lineColor: UIColor(hex: "#333334") ?? .black
            ),
            basicTextStyle: Button.Data.Text.Style(
                normal: UIColor(hex: "#333334"),
                highlighted: nil,
                disabled: nil
            )
        )
    }

    // Secondary

    static var secondary: Self {
        Self(
            background: .color(
                normal: UIColor(hex: "#F7F8F9"),
                highlighted: UIColor(hex: "#EFF0F2"),
                disabled: nil
            ),
            cornerRadius: .defaultCornerRadius,
            loaderStyle: ActivityIndicatorView.Style(
                lineColor: UIColor(hex: "#428BFA") ?? .black
            ),
            basicTextStyle: Button.Data.Text.Style(
                normal: UIColor(hex: "#428BFA"),
                highlighted: nil,
                disabled: nil
            )
        )
    }

    // Destructive

    static var destructive: Self {
        Self(
            background: .color(
                normal: UIColor(hex: "#F7F8F9"),
                highlighted: UIColor(hex: "#EFF0F2"),
                disabled: nil
            ),
            cornerRadius: .defaultCornerRadius,
            loaderStyle: ActivityIndicatorView.Style(
                lineColor: UIColor(hex: "#F52323") ?? .black
            ),
            basicTextStyle: Button.Data.Text.Style(
                normal: UIColor(hex: "#F52323"),
                highlighted: nil,
                disabled: nil
            )
        )
    }
}

private extension CGFloat {

    static let defaultCornerRadius: CGFloat = 16
}
