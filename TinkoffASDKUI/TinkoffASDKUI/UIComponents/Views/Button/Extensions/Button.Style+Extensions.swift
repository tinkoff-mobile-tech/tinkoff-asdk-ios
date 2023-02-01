//
//  Button.Style+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 01.02.2023.
//

import Foundation

extension Button.Style {
    static var clear: Button.Style {
        Button.Style(foregroundColor: .clear, backgroundColor: .clear)
    }

    // MARK: Design System

    static var primaryTinkoff: Button.Style {
        Button.Style(
            foregroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Text.primaryOnTinkoff.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Foreground.brandTinkoffAccent,
                disabled: ASDKColors.Background.neutral1.color
            )
        )
    }

    static var secondary: Button.Style {
        Button.Style(
            foregroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Text.accent.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Background.neutral1.color,
                disabled: ASDKColors.Background.neutral1.color
            )
        )
    }

    static var flat: Button.Style {
        Button.Style(
            foregroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Text.accent.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Button.InteractiveColor(
                normal: .clear,
                highlighted: ASDKColors.Background.neutral1.color,
                disabled: .clear
            )
        )
    }

    static var destructive: Button.Style {
        Button.Style(
            foregroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Text.negative.color,
                disabled: ASDKColors.Text.tertiary.color
            ),
            backgroundColor: Button.InteractiveColor(
                withDefaultHighlight: ASDKColors.Background.neutral1.color,
                disabled: ASDKColors.Background.neutral1.color
            )
        )
    }
}
