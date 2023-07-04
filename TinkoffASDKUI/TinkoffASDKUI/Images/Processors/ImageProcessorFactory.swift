//
//  ImageProcessorFactory.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 03.07.2023.
//

import UIKit

protocol IImageProcessorFactory {
    func makeImageProcesssors(for type: CellImageLoaderType) -> [ImageProcessor]
}

final class ImageProcessorFactory: IImageProcessorFactory {
    func makeImageProcesssors(for type: CellImageLoaderType) -> [ImageProcessor] {
        let scale = UIScreen.main.scale

        switch type {
        case .round:
            return [RoundImageProcessor()]
        case let .size(size):
            return [SizeImageProcessor(size: size, scale: scale)]
        case let .roundAndSize(size):
            return [RoundImageProcessor(), SizeImageProcessor(size: size, scale: scale)]
        case .default:
            return []
        }
    }
}
