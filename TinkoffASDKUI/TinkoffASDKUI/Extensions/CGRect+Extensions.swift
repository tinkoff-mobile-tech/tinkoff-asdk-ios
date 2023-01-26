//
//  CGRect+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 25.01.2023.
//

import CoreGraphics

extension CGRect {
    var center: CGPoint {
        get { CGPoint(x: midX, y: midY) }
        set {
            origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2)
        }
    }
}
