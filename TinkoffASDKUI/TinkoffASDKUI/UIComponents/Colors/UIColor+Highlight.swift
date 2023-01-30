//
//  UIColor+Highlight.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import UIKit

extension UIColor {
    func highlighted(
        traitCollection: UITraitCollection,
        settings: HighlightSettings
    ) -> UIColor {
        let color: UIColor = {
            if #available(iOS 13, *) {
                return resolvedColor(with: traitCollection)
            } else {
                return self
            }
        }()

        return color
            .hsbaColor
            .highlighted(
                theme: traitCollection.theme,
                settings: settings
            ).uiColor
    }
}
