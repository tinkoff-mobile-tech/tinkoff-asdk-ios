//
//  UIColor+Dynamic.swift
//  TinkoffASDKUI
//
//  Created by grisha on 07.12.2020.
//

import UIKit

extension UIColor {

    struct Dynamic {
        let light: UIColor
        let dark: UIColor

        var color: UIColor {
            UIColor.dynamicColor(dynamic: self)
        }

        var oppositeColor: UIColor {
            UIColor.getOppositeColor(dynamic: self)
        }

        // MARK: - Static

        static let basic = Self(light: .black, dark: .white)
    }
}

extension UIColor {

    static func dynamicColor(dynamic: Dynamic) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: {
                postUserInterfaceStyleDidChangeIfNeeded(style: $0.userInterfaceStyle)
                return $0.userInterfaceStyle == .dark ? dynamic.dark : dynamic.light
            })
        }
        return dynamic.light
    }

    static func getOppositeColor(dynamic: Dynamic) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor(dynamicProvider: {
                $0.userInterfaceStyle == .dark ? dynamic.light : dynamic.dark
            })
        }
        return dynamic.dark
    }

    private static func postUserInterfaceStyleDidChangeIfNeeded(style: UIUserInterfaceStyle) {
        guard UIScreen.main.traitCollection.userInterfaceStyle != style
        else { return }
        NotificationCenter.default.post(
            name: .userInterfaceStyleDidChange,
            object: self,
            userInfo: [Notification.Keys.value: style]
        )
    }
}
