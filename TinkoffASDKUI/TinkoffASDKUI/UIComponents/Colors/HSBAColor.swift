//
//  HSBAColor.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import CoreGraphics

struct HSBAColor: CustomStringConvertible {
    let hue: CGFloat
    let saturation: CGFloat
    let brightness: CGFloat
    let alpha: CGFloat

    var intHue: UInt16 {
        UInt16(normalized: hue, max: 360)
    }

    var intSaturation: UInt8 {
        UInt8(normalized: saturation, max: .max)
    }

    var intBrightness: UInt8 {
        UInt8(normalized: brightness, max: .max)
    }

    var intAlpha: UInt8 {
        UInt8(normalized: alpha, max: 100)
    }

    var description: String {
        "HSBA(\(intHue), \(intSaturation), \(intBrightness), \(intAlpha))"
    }

    init(
        hue: CGFloat,
        saturation: CGFloat,
        brightness: CGFloat,
        alpha: CGFloat
    ) {
        assert(hue.isNormalized())
        assert(saturation.isNormalized())
        assert(brightness.isNormalized())
        assert(alpha.isNormalized())
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.alpha = alpha
    }
}

private extension CGFloat {
    func isNormalized() -> Bool {
        self >= 0 && self <= 1
    }
}

extension UInt8 {
    init(normalized value: CGFloat, max: UInt8) {
        self.init(round(value * CGFloat(max)))
    }
}

extension UInt16 {
    init(normalized value: CGFloat, max: UInt16) {
        self.init(round(value * CGFloat(max)))
    }
}
