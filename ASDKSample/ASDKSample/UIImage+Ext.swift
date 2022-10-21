//
//
//  UIImage+Ext.swift
//
//  Copyright (c) 2021 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import CoreGraphics
import UIKit

extension UIImage {

    /// Добавляет отступы, не меняя размер первоначальной картинки.
    func addInsetsInside(inset: UInt) -> UIImage? {
        addInsetsInside(hInset: inset, vInset: inset)
    }

    /// Добавляет отступы, не меняя размер первоначальной картинки.
    func addInsetsInside(hInset: UInt, vInset: UInt) -> UIImage? {
        let imageSize = CGSize(
            width: size.width - CGFloat(hInset * 2),
            height: size.height - CGFloat(vInset * 2)
        )

        // sanity check
        assert(imageSize.width > 0 && imageSize.height > 0)

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(
            in: CGRect(
                x: CGFloat(hInset),
                y: CGFloat(vInset),
                width: imageSize.width,
                height: imageSize.height
            )
        )
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func resizeImageVerticallyIfNeeded(fitSize: CGSize) -> UIImage {
        var proccessedImage = self

        if proccessedImage.size.height != fitSize.height {
            let scaleFactor = fitSize.height / proccessedImage.size.height

            let width = proccessedImage.size.width * scaleFactor
            let height = proccessedImage.size.height * scaleFactor

            let newSize = CGSize(width: width, height: height)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)

            proccessedImage = renderer.image { _ in
                draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        }

        if proccessedImage.size.width < fitSize.height {
            let scaleFactor = fitSize.height / proccessedImage.size.width

            let width = proccessedImage.size.width * scaleFactor

            let newSize = CGSize(width: width, height: proccessedImage.size.height * scaleFactor)
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            let renderer = UIGraphicsImageRenderer(size: newSize, format: format)

            proccessedImage = renderer.image { _ in
                draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        }

        return proccessedImage
    }
}
