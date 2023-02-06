//
//  HSBAColor+Highlight.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import CoreGraphics

extension HSBAColor {
    func highlighted(
        theme: Theme,
        settings: HighlightSettings
    ) -> HSBAColor {
        var brightnessAdjustment = settings.brightnessAdjustment(theme: theme)
        var hueAdjustment: CGFloat = 0
        var alphaMultiplier: CGFloat = 1

        if let params = settings.adjustAlpha {
            if alpha <= params.upperBounds {
                alphaMultiplier = params.maxMultiplier
                brightnessAdjustment = 0
            } else {
                alphaMultiplier = params.multiplier(alpha: alpha)
                let progress = (1 ... params.maxMultiplier).progress(for: alphaMultiplier)
                let range: ClosedRange<CGFloat>
                let progressToApply: CGFloat
                if brightnessAdjustment > 0 {
                    range = 0 ... brightnessAdjustment
                    progressToApply = 1 - progress
                } else {
                    range = brightnessAdjustment ... 0
                    progressToApply = progress
                }
                brightnessAdjustment = range.with(progress: progressToApply)
            }
        }

        if let params = settings.adjustYellow,
           params.hueRange.contains(hue),
           brightness > (1 - abs(brightnessAdjustment)) {
            hueAdjustment = params.hueAdjustment
            brightnessAdjustment = params.brightnessAdjustment
        }

        return adjustHue(by: hueAdjustment)
            .adjustBrightness(by: brightnessAdjustment)
            .with(alpha: (alpha * alphaMultiplier).clamp(0 ... 1))
    }
}

private extension Comparable {
    func clamp(_ limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}

private extension ClosedRange where Bound == CGFloat {
    func with(progress: CGFloat) -> CGFloat {
        assert(progress >= 0 && progress <= 1)
        return lowerBound + progress * (upperBound - lowerBound)
    }

    func progress(for value: CGFloat) -> CGFloat {
        assert(contains(value))
        return (value - lowerBound) / (upperBound - lowerBound)
    }
}

private extension HSBAColor {
    func with(alpha newValue: CGFloat) -> Self {
        HSBAColor(hue: hue, saturation: saturation, brightness: brightness, alpha: newValue)
    }

    func adjustHue(by adjustment: CGFloat) -> Self {
        let adjusted: CGFloat
        if (0.0 ... 1.0).contains(hue + adjustment) {
            adjusted = hue + adjustment
        } else {
            assert((0.0 ... 1.0).contains(hue - adjustment))
            adjusted = (hue - adjustment).clamp(0 ... 1)
        }
        return HSBAColor(hue: adjusted, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    func adjustBrightness(by adjustment: CGFloat) -> Self {
        let adjusted: CGFloat
        if (0.0 ... 1.0).contains(brightness + adjustment) {
            adjusted = brightness + adjustment
        } else {
            assert((0.0 ... 1.0).contains(brightness - adjustment))
            adjusted = (brightness - adjustment).clamp(0 ... 1)
        }
        return HSBAColor(hue: hue, saturation: saturation, brightness: adjusted, alpha: alpha)
    }
}

private extension HighlightSettings.Alpha {
    func multiplier(alpha: CGFloat) -> CGFloat {
        let from = CGPoint(x: upperBounds, y: maxMultiplier)
        let to = CGPoint(x: 1, y: 1)
        return getLinearInterpolatedY(p1: from, p2: to, x: alpha)
    }
}

private func getLinearInterpolatedY(p1: CGPoint, p2: CGPoint, x: CGFloat) -> CGFloat {
    let k = (p1.y - p2.y) / (p1.x - p2.x)
    let b = p2.y - k * p2.x
    return k * x + b
}
