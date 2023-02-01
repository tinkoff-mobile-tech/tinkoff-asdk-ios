//
//  Button+Style2.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import UIKit

extension Button {
    struct Style2: Equatable {
        var foregroundColor: Color
        var backgroundColor: Color
    }
}

// MARK: - Button.Style + Color

extension Button.Style2 {
    struct Color: Equatable {
        var normal: UIColor
        var highlighted: UIColor
        var disabled: UIColor
    }
}

// MARK: - Button.Style.Color + Helpers

extension Button.Style2.Color {
    static var clear: Button.Style2.Color {
        Button.Style2.Color(normal: .clear, highlighted: .clear, disabled: .clear)
    }

    init(withDefaultHighlight defaultColor: UIColor, disabled: UIColor) {
        self.init(
            normal: defaultColor,
            highlighted: defaultColor.highlighted(),
            disabled: disabled
        )
    }
}

// MARK: - Button.Style + Styles

extension Button.Style2 {
    static var clear: Button.Style2 {
        Button.Style2(foregroundColor: .clear, backgroundColor: .clear)
    }

    static var primaryTinkoff: Button.Style2 {
        Button.Style2(
            foregroundColor: Color(
                withDefaultHighlight: ASDKColors.Text.primaryOnTinkoff.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Color(
                withDefaultHighlight: ASDKColors.Foreground.brandTinkoffAccent,
                disabled: ASDKColors.Background.neutral1.color
            )
        )
    }

    static var secondary: Button.Style2 {
        Button.Style2(
            foregroundColor: Color(
                withDefaultHighlight: ASDKColors.Text.accent.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Color(
                withDefaultHighlight: ASDKColors.Background.neutral1.color,
                disabled: ASDKColors.Background.neutral1.color
            )
        )
    }

    static var flat: Button.Style2 {
        Button.Style2(
            foregroundColor: Color(
                withDefaultHighlight: ASDKColors.Text.accent.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Color(
                normal: .clear,
                highlighted: ASDKColors.Background.neutral1.color,
                disabled: .clear
            )
        )
    }

    static var destructive: Button.Style2 {
        Button.Style2(
            foregroundColor: Color(
                withDefaultHighlight: ASDKColors.Text.negative.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Color(
                withDefaultHighlight: ASDKColors.Background.neutral1.color,
                disabled: ASDKColors.Background.neutral1.color
            )
        )
    }
}
