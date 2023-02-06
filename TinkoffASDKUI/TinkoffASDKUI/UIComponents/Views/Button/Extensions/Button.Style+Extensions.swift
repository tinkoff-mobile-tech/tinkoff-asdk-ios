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
                normal: ASDKColors.Text.primaryOnTinkoff.color
            ),
            backgroundColor: Button.InteractiveColor(
                normal: ASDKColors.Foreground.brandTinkoffAccent
            )
        )
    }

    static var secondary: Button.Style {
        Button.Style(
            foregroundColor: Button.InteractiveColor(
                normal: ASDKColors.Text.accent.color
            ),
            backgroundColor: Button.InteractiveColor(
                normal: ASDKColors.Background.neutral1.color
            )
        )
    }

    static var flat: Button.Style {
        Button.Style(
            foregroundColor: Button.InteractiveColor(
                normal: ASDKColors.Text.accent.color
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
                normal: ASDKColors.Text.negative.color
            ),
            backgroundColor: Button.InteractiveColor(
                normal: ASDKColors.Background.neutral1.color
            )
        )
    }
}
