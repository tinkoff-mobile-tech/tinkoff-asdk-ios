//
//  Button+Configuration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 27.01.2023.
//

import UIKit

// MARK: - Button + Configuration

extension Button {
    struct Configuration2 {
        var style: Style2 = .primary
        var title: String?
        var icon: UIImage?
        var action: VoidBlock?
    }
}

// MARK: - Button + TitleColor

extension Button {
    struct TitleColor {
        var normal: UIColor
        var highlighted: UIColor
        var disabled: UIColor
    }
}

extension Button.TitleColor {
    init(_ color: UIColor) {
        self.init(normal: color, highlighted: color, disabled: color)
    }
}

// MARK: - Button + BackgroundColor

extension Button {
    struct BackgroundColor {
        var normal: UIColor
        var highlighted: UIColor
        var disabled: UIColor
    }
}

extension Button.BackgroundColor {
    init(_ color: UIColor) {
        self.init(normal: color, highlighted: color, disabled: color)
    }
}

// MARK: - Button + Style

extension Button {
    struct Style2 {
        var titleColor = TitleColor(
            normal: ASDKColors.Text.primaryOnTinkoff.color,
            highlighted: ASDKColors.Text.primaryOnTinkoff.color,
            disabled: ASDKColors.Text.tertiary.color
        )
        var backgroundColor = BackgroundColor(
            normal: ASDKColors.Foreground.brandTinkoffAccent,
            highlighted: UIColor(hex: "#FFCD33") ?? .clear,
            disabled: ASDKColors.Background.neutral1.color
        )
        var font: UIFont = .systemFont(ofSize: 17, weight: .regular)
        var cornerRadius: CGFloat = 16
        var loaderStyle = ActivityIndicatorView.Style(lineColor: UIColor(hex: "#333334") ?? .black)
        var contentEdgeInsets = UIEdgeInsets(vertical: 8, horizontal: 16)
    }
}

// MARK: - Button.Style + Presets

extension Button.Style2 {
    static var primary: Self {
        Self()
    }

    static var secondary: Self {
        Self(
            titleColor: Button.TitleColor(UIColor(hex: "#428BFA") ?? .clear),
            backgroundColor: Button.BackgroundColor(
                normal: ASDKColors.Background.neutral1.color,
                highlighted: UIColor(hex: "#EFF0F2") ?? .clear,
                disabled: ASDKColors.Background.neutral1.color
            ),
            font: .systemFont(ofSize: 16, weight: .regular),
            loaderStyle: ActivityIndicatorView.Style(lineColor: UIColor(hex: "#428BFA") ?? .black)
        )
    }

    static var destructive: Button.Style2 {
        Button.Style2(
            titleColor: Button.TitleColor(UIColor(hex: "#F52323") ?? .clear),
            backgroundColor: Button.BackgroundColor(
                normal: ASDKColors.Background.neutral1.color,
                highlighted: UIColor(hex: "#EFF0F2") ?? .clear,
                disabled: ASDKColors.Background.neutral1.color
            ),
            font: .systemFont(ofSize: 16, weight: .regular),
            loaderStyle: ActivityIndicatorView.Style(lineColor: UIColor(hex: "#F52323") ?? .black)
        )
    }
}
