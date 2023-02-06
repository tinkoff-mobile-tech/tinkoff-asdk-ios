//
//  Button+ContentSize.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import Foundation

extension Button.ContentSize {
    static var basicSmall: Button.ContentSize {
        Button.ContentSize(
            titleFont: .uiSmallBold,
            cornersStyle: .rounded(radius: 12),
            activityIndicatorDiameter: 20,
            imagePadding: 4,
            preferredHeight: 30,
            contentInsets: UIEdgeInsets(side: 7)
        )
    }

    static var basicMedium: Button.ContentSize {
        Button.ContentSize(
            titleFont: .bodyMedium,
            cornersStyle: .rounded(radius: 12),
            activityIndicatorDiameter: 24,
            imagePadding: 8,
            preferredHeight: 44,
            contentInsets: UIEdgeInsets(side: 10)
        )
    }

    static var basicLarge: Button.ContentSize {
        Button.ContentSize(
            titleFont: .bodyLarge,
            cornersStyle: .rounded(radius: 16),
            activityIndicatorDiameter: 24,
            imagePadding: 8,
            preferredHeight: 56,
            contentInsets: UIEdgeInsets(side: 10)
        )
    }
}
