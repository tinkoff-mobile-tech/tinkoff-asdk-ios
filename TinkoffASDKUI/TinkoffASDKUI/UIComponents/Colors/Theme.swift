//
//  Theme.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import UIKit

enum Theme {
    case light
    case dark
}

extension UITraitCollection {
    static var theme: Theme {
        if #available(iOS 13, *) {
            return UITraitCollection.current.theme
        } else {
            return UIScreen.main.traitCollection.theme
        }
    }

    var theme: Theme {
        if #available(iOS 12.0, *) {
            return userInterfaceStyle.cast()
        } else {
            return .light
        }
    }
}

@available(iOS 12.0, *)
private extension UIUserInterfaceStyle {
    func cast() -> Theme {
        switch self {
        case .dark: return .dark
        case .light, .unspecified: return .light
        @unknown default:
            return .light
        }
    }
}
