//
//  Button+ContentSize.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 30.01.2023.
//

import Foundation

// MARK: - Button + ContentSize

extension Button {
    struct ContentSize: Equatable {
        var titleFont: UIFont?
        var cornersStyle: CornersStyle = .none
        var activityIndicatorDiameter: CGFloat = .zero
        var imagePadding: CGFloat = .zero
        var minHeight: CGFloat = .zero
        var contentInsets: UIEdgeInsets = .zero
    }
}

extension Button.ContentSize {
    enum CornersStyle: Equatable {
        case none
        case rounded(radius: CGFloat)
    }
}

extension Button.ContentSize.CornersStyle {
    func cornerRadius(for bounds: CGRect) -> CGFloat {
        switch self {
        case .none:
            return .zero
        case let .rounded(radius):
            return radius
        }
    }
}

extension Button.ContentSize {
    static var basicLarge: Button.ContentSize {
        Button.ContentSize(
            titleFont: .systemFont(ofSize: 17, weight: .regular),
            cornersStyle: .rounded(radius: 16),
            activityIndicatorDiameter: 24,
            imagePadding: 8,
            minHeight: 56,
            contentInsets: UIEdgeInsets(side: 10)
        )
    }

    static var basicMedium: Button.ContentSize {
        Button.ContentSize(
            titleFont: .systemFont(ofSize: 15, weight: .regular),
            cornersStyle: .rounded(radius: 12),
            activityIndicatorDiameter: 24,
            imagePadding: 8,
            minHeight: 44,
            contentInsets: UIEdgeInsets(vertical: 16, horizontal: 16)
        )
    }
}
