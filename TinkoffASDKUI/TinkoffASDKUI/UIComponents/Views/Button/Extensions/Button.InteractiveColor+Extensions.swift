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
}
