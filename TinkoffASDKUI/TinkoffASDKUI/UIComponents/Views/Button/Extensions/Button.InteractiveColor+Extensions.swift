//
//  Button.InteractiveColor+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 01.02.2023.
//

import Foundation

extension Button.InteractiveColor {
    static var clear: Button.InteractiveColor {
        Button.InteractiveColor(normal: .clear, highlighted: .clear, disabled: .clear)
    }

    init(withDefaultHighlight defaultColor: UIColor, disabled: UIColor) {
        self.init(
            normal: defaultColor,
            highlighted: defaultColor.highlighted(),
            disabled: disabled
        )
    }

    func forState(_ state: UIControl.State) -> UIColor {
        switch state {
        case .highlighted:
            return highlighted
        case .disabled:
            return disabled
        default:
            return normal
        }
    }
}
