//
//  UITraintCollection+Utils.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import UIKit

extension UITraitCollection {
    enum ColorTheme {
        case light
        case dark
    }

    static var colorTheme: ColorTheme {
        if #available(iOS 13, *) {
            return ColorTheme(from: UITraitCollection.current.userInterfaceStyle)
        } else {
            return .light
        }
    }
}

// MARK: - UITraitCollection.ColorTheme + UIUserInterfaceStyle

extension UITraitCollection.ColorTheme {
    init(from userInterfaceStyle: UIUserInterfaceStyle) {
        switch userInterfaceStyle {
        case .dark:
            self = .dark
        default:
            self = .light
        }
    }
}
