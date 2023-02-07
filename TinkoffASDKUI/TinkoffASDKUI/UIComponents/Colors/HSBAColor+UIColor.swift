//
//  HSBAColor+UIColor.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import CoreGraphics
import UIKit

extension HSBAColor {
    var uiColor: UIColor {
        UIColor(
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            alpha: alpha
        )
    }
}

extension UIColor {
    var hsbaColor: HSBAColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return HSBAColor(
            hue: h,
            saturation: s,
            brightness: b,
            alpha: a
        )
    }
}
