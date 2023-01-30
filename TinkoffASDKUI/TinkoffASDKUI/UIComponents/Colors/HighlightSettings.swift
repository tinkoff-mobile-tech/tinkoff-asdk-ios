//
//  HighlightSettings.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import CoreGraphics

struct HighlightSettings: Equatable {
    struct Yellow: Equatable {
        var hueRange: ClosedRange<CGFloat>
        var brightnessAdjustment: CGFloat
        var hueAdjustment: CGFloat

        static let `default` = Yellow(
            hueRange: 45 / 360 ... 60 / 360,
            brightnessAdjustment: -0.02,
            hueAdjustment: -3 / 360
        )
    }

    struct Alpha: Equatable {
        var upperBounds: CGFloat
        var maxMultiplier: CGFloat

        static let `default` = Alpha(
            upperBounds: 0.9,
            maxMultiplier: 2
        )
    }

    struct ThemeSettings: Equatable {
        var brightnessAdjustment: CGFloat

        static let `default` = ThemeSettings(
            brightnessAdjustment: 0
        )
    }

    // MARK: - Public Properties

    var dark: ThemeSettings
    var light: ThemeSettings
    var adjustYellow: FeatureWithParams<Yellow>
    var adjustAlpha: FeatureWithParams<Alpha>

    // MARK: - Methods

    func brightnessAdjustment(theme: Theme) -> CGFloat {
        switch theme {
        case .dark:
            return dark.brightnessAdjustment
        case .light:
            return light.brightnessAdjustment
        }
    }

    mutating func set(brightnessAdjustment: CGFloat, theme: Theme) {
        switch theme {
        case .dark:
            dark.brightnessAdjustment = brightnessAdjustment
        case .light:
            light.brightnessAdjustment = brightnessAdjustment
        }
    }
}

// MARK: - Static

extension HighlightSettings {
    /// A constant representing the default value for highlight settings.
    static let `default` = HighlightSettings(
        dark: ThemeSettings(brightnessAdjustment: 0.07),
        light: ThemeSettings(brightnessAdjustment: -0.05),
        adjustYellow: .on(params: .default),
        adjustAlpha: .on(params: .default)
    )
    /// A constant representing no highlight value.
    static let none = HighlightSettings(
        dark: .default,
        light: .default,
        adjustYellow: .off,
        adjustAlpha: .off
    )
}
