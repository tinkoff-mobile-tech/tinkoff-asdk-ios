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
    @discardableResult
    func loadRemoteImage(url: URL, imageView: UIImageView) -> UUID?

    func cancelLoadIfNeeded(imageView: UIImageView)

    func set(type: CellImageLoaderType)
}

final class CellImageLoader: ICellImageLoader {
    static let loader: ICellImageLoader = CellImageLoader(imageLoader: ImageLoader())

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

    func loadImage(url: URL, cell: ReusableCell) {
        if url.isFileURL {
            loadLocalImage(url: url, cell: cell)
        } else {
            loadRemoteImage(url: url, cell: cell)
        }
    }
}

// MARK: - ICellImageLoader

extension CellImageLoader {
    @discardableResult
    func loadRemoteImage(url: URL, imageView: UIImageView) -> UUID? {
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
                    break
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
}

// MARK: - Private

private extension CellImageLoader {
    func loadLocalImage(url: URL, imageView: UIImageView) {
        guard let imageData = try? Data(contentsOf: url),
              let image = UIImage(data: imageData) else {
            return
        }
        imageView.image = image
    }

    func loadLocalImage(url: URL, cell: ReusableCell) {
        guard let imageView = cell.imageView else { return }

        loadLocalImage(url: url, imageView: imageView)
    }

    func loadRemoteImage(url: URL, cell: ReusableCell) {
        guard let imageView = cell.imageView else { return }

        let uuid = loadRemoteImage(url: url, imageView: imageView)

        guard let cellUuid = uuid else { return }
        cell.onReuse = { [weak self] in
            self?.cancelLoadIfNeeded(imageView: imageView)
            self?.imageLoader.cancelImageLoad(uuid: cellUuid)
        }
    }
}
