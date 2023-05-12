//
//  Button.CornerStyle+Extensions.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 01.02.2023.
//

import UIKit

extension Button.CornersStyle {
    func cornerRadius(for bounds: CGRect) -> CGFloat {
        switch self {
        case .none:
            return .zero
        case let .rounded(radius):
            return radius
        }
    }
}
