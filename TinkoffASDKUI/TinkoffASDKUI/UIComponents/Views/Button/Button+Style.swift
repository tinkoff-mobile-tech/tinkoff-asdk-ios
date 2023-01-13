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

        var background: Background
        var cornerRadius: CGFloat
        let loaderStyle: ActivityIndicatorView.Style
        var contentEdgeInsets: UIEdgeInsets

        var basicTextStyle: Data.Text.Style?

        func set(contentEdgeInsets: UIEdgeInsets) -> Self {
            var shadowCopy = self
            shadowCopy.contentEdgeInsets = contentEdgeInsets
            return shadowCopy
        }

        func set(font: UIFont) -> Self {
            var shadowCopy = self
            shadowCopy.basicTextStyle?.font = font
            return shadowCopy
        }

        func set(cornerRadius: CGFloat) -> Self {
            var shadowCopy = self
            shadowCopy.cornerRadius = cornerRadius
            return shadowCopy
        }

        func set(basicTextStyle: Data.Text.Style?) -> Self {
            var shadowCopy = self
            shadowCopy.basicTextStyle = basicTextStyle
            return shadowCopy
        }

        func set(background: Background) -> Self {
            var shadowCopy = self
            shadowCopy.background = background
            return shadowCopy
        }
    }
}

extension Button.Data.Text {

    struct Style {
        var normal: UIColor?
        var highlighted: UIColor?
        var disabled: UIColor?

        var font: UIFont? = .systemFont(ofSize: 16)

        func setFont(_ font: UIFont) -> Self {
            var shadowCopy = self
            shadowCopy.font = font
            return shadowCopy
        }

        func setNormal(textColor: UIColor) -> Self {
            var shadowCopy = self
            shadowCopy.normal = textColor
            return shadowCopy
        }

        func setHighlighted(textColor: UIColor) -> Self {
            var shadowCopy = self
            shadowCopy.highlighted = textColor
            return shadowCopy
        }

        func setDisable(textColor: UIColor) -> Self {
            var shadowCopy = self
            shadowCopy.disabled = textColor
            return shadowCopy
        }
    }
}

// MARK: - Styles

extension Button.Style {

    // Primary

    static var primary: Self {
        Self(
            background: .color(
                normal: ASDKColors.Foreground.brandTinkoffAccent,
                highlighted: UIColor(hex: "#FFCD33"),
                disabled: ASDKColors.Background.neutral1.color
            ),
            cornerRadius: .defaultCornerRadius,
            loaderStyle: ActivityIndicatorView.Style(
                lineColor: UIColor(hex: "#333334") ?? .black
            ),
            contentEdgeInsets: UIEdgeInsets(vertical: 8, horizontal: 16),
            basicTextStyle: Button.Data.Text.Style(
                normal: ASDKColors.Text.primaryOnTinkoff.color,
                highlighted: ASDKColors.Text.primaryOnTinkoff.color,
                disabled: ASDKColors.Text.tertiary.color,
                font: UILabel.Style.bodyL().font
            )
        )
    }

    // Secondary

    static var secondary: Self {
        Self(
            background: .color(
                normal: ASDKColors.Background.neutral1.color,
                highlighted: UIColor(hex: "#EFF0F2"),
                disabled: nil
            ),
            cornerRadius: .defaultCornerRadius,
            loaderStyle: ActivityIndicatorView.Style(
                lineColor: UIColor(hex: "#428BFA") ?? .black
            ),
            contentEdgeInsets: UIEdgeInsets(vertical: 8, horizontal: 16),
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
                normal: ASDKColors.Background.neutral1.color,
                highlighted: UIColor(hex: "#EFF0F2"),
                disabled: nil
            ),
            cornerRadius: .defaultCornerRadius,
            loaderStyle: ActivityIndicatorView.Style(
                lineColor: UIColor(hex: "#F52323") ?? .black
            ),
            contentEdgeInsets: UIEdgeInsets(vertical: 8, horizontal: 16),
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
