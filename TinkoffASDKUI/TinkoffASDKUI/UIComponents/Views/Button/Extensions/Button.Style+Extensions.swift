//
//  Button.Style+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 01.02.2023.
//

import Foundation

extension Button.Style2 {
    static var clear: Button.Style2 {
        Button.Style2(foregroundColor: .clear, backgroundColor: .clear)
    }

    // MARK: Design System

    static var primaryTinkoff: Button.Style2 {
        Button.Style2(
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

    static var secondary: Button.Style2 {
        Button.Style2(
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

    static var flat: Button.Style2 {
        Button.Style2(
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

    static var destructive: Button.Style2 {
        Button.Style2(
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
