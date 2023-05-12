//
//
//  CellImageLoader.swift
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

import UIKit

enum CellImageLoaderType: Equatable {
    case round
    case size(CGSize)
    case roundAndSize(CGSize)
    case `default`
}

protocol ICellImageLoader {
    func loadImage(url: URL, completion: @escaping (Result<UIImage, Swift.Error>) -> Void)

    @discardableResult
    func loadAndSetRemoteImage(url: URL, imageView: UIImageView, onFailureImage: UIImage?) -> UUID?
    func cancelLoadIfNeeded(imageView: UIImageView)

    @discardableResult
    func loadRemoteImageJustForCache(url: URL) -> UUID?
    func cancelLoad(uuid: UUID)

    func set(type: CellImageLoaderType)
}

final class CellImageLoader: ICellImageLoader {

    private let imageLoader: ImageLoader
    private var imageProcessors = [ImageProcessor]()

    private var requests = [UIImageView: UUID]()

    private var type: CellImageLoaderType = .default {
        didSet {
            let scale = UIScreen.main.scale

            switch type {
            case .round:
                imageProcessors = [RoundImageProcessor()]
            case let .size(size):
                imageProcessors = [SizeImageProcessor(size: size, scale: scale)]
            case let .roundAndSize(size):
                imageProcessors = [RoundImageProcessor(), SizeImageProcessor(size: size, scale: scale)]
            case .default:
                imageProcessors = []
            }
        }
    }

    init(imageLoader: ImageLoader, type: CellImageLoaderType = .default) {
        self.imageLoader = imageLoader
        self.type = type
    }

    func set(type: CellImageLoaderType) {
        guard self.type != type else { return }

        self.type = type
    }
}

// MARK: - ICellImageLoader

extension CellImageLoader {
    func loadImage(url: URL, completion: @escaping (Result<UIImage, Swift.Error>) -> Void) {
        imageLoader.loadImage(url: url) { [weak self] image in
            guard let self = self else { return image }
            return self.imageProcessors.reduce(image) { image, processor -> UIImage in
                processor.processImage(image)
            }
        } completion: { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    @discardableResult
    func loadAndSetRemoteImage(url: URL, imageView: UIImageView, onFailureImage: UIImage? = nil) -> UUID? {
        cancelLoadIfNeeded(imageView: imageView)

        let uuid = imageLoader.loadImage(url: url) { [weak self] image in
            guard let self = self else { return image }
            return self.imageProcessors.reduce(image) { image, processor -> UIImage in
                processor.processImage(image)
            }
        } completion: { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    imageView.image = image
                case .failure:
                    imageView.image = onFailureImage
                }

                self?.requests.removeValue(forKey: imageView)
            }
        }

        requests[imageView] = uuid

        return uuid
    }

    func cancelLoadIfNeeded(imageView: UIImageView) {
        if let uuid = requests[imageView] {
            imageLoader.cancelImageLoad(uuid: uuid)
            requests.removeValue(forKey: imageView)
        }
    }

    @discardableResult
    func loadRemoteImageJustForCache(url: URL) -> UUID? {
        return imageLoader.loadImage(url: url) { [weak self] image in
            guard let self = self else { return image }
            return self.imageProcessors.reduce(image) { image, processor -> UIImage in
                processor.processImage(image)
            }
        } completion: { _ in }
    }

    func cancelLoad(uuid: UUID) {
        imageLoader.cancelImageLoad(uuid: uuid)
    }
}
