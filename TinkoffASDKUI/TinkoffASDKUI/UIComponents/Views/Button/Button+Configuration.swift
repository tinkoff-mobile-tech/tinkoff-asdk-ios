//
//  Button+Configuration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 27.01.2023.
//

import UIKit

extension Button {
    struct Configuration: Equatable {
        var title: String?
        var icon: UIImage?
        var style: Style = .clear
        var contentSize = ContentSize()
        var imagePlacement: ImagePlacement = .leading
        var loaderVisible = false
    }

    struct Style: Equatable {
        var foregroundColor: InteractiveColor
        var backgroundColor: InteractiveColor
    }

    struct ContentSize: Equatable {
        var titleFont: UIFont?
        var cornersStyle: CornersStyle = .none
        var activityIndicatorDiameter: CGFloat = .zero
        var imagePadding: CGFloat = .zero
        var preferredHeight: CGFloat = .zero
        var contentInsets: UIEdgeInsets = .zero
    }

    enum CornersStyle: Equatable {
        case none
        case rounded(radius: CGFloat)
    }

    struct InteractiveColor: Equatable {
        var normal: UIColor
        var highlighted: UIColor
        var disabled: UIColor
    }

    enum ImagePlacement {
        case leading
        case trailing
    }
}
