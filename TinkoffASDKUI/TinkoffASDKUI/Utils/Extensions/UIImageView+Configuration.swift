//
//  UIImageView+Configuration.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 12.12.2022.
//

import UIKit

extension UIImageView: Reusable {

    func configure(with config: Configuration) {
        image = config.image
        contentMode = config.contentMode
        clipsToBounds = config.clipsToBounds
        layer.cornerRadius = config.cornerRadius
    }

    func prepareForReuse() {
        image = nil
        contentMode = .scaleAspectFill
        clipsToBounds = false
        layer.cornerRadius = .zero
    }
}

extension UIImageView {

    struct Configuration {
        let image: UIImage?
        let contentMode: ContentMode
        var clipsToBounds = true
        var cornerRadius: CGFloat = .zero

        static var empty: Self {
            Self(image: nil, contentMode: .scaleAspectFill)
        }
    }
}
