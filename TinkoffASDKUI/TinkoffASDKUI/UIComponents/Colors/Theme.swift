//
//  Theme.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import UIKit

@frozen public enum Theme {
    case light
    case dark
}

public extension UITraitCollection {
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
