//
//  UITraintCollection+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import UIKit

enum ColorTheme {
    case light
    case dark
}

extension UITraitCollection {
    static var colorTheme: ColorTheme {
        if #available(iOS 13, *) {
            return ColorTheme(from: UITraitCollection.current.userInterfaceStyle)
        } else {
            return ColorTheme(from: UIScreen.main.traitCollection.userInterfaceStyle)
        }
    }
}

extension ColorTheme {
    init(from userInterfaceStyle: UIUserInterfaceStyle) {
        switch userInterfaceStyle {
        case .dark:
            self = .dark
        case .unspecified, .light:
            self = .light
        @unknown default:
            self = .light
        }
    }
}
