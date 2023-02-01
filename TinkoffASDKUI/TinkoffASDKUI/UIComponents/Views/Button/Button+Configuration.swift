//
//  Button+Configuration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 27.01.2023.
//

import UIKit

extension Button {
    struct Configuration2: Equatable {
        var style: Style2
        var contentSize: ContentSize
        var title: String?
        var icon: UIImage?
        var imagePlacement: ImagePlacement = .leading
    }
}

// MARK: - Button.Configuration + Helpers

extension Button.Configuration2 {
    static var empty: Button.Configuration2 {
        Button.Configuration2(
            style: .clear,
            contentSize: Button.ContentSize()
        )
    }
}

// MARK: - Button + ImagePlacement

extension Button {
    enum ImagePlacement {
        case leading
        case trailing
    }
}
