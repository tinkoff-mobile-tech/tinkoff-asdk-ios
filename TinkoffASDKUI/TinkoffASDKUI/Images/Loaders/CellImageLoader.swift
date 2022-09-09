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

final class CellImageLoader {
    private let imageLoader: ImageLoader
    private var imageProcessors = [ImageProcessor]()

    init(imageLoader: ImageLoader) {
        self.imageLoader = imageLoader
    }

    func setImageProcessors(_ imageProcessors: [ImageProcessor]) {
        self.imageProcessors = imageProcessors
    }

    func loadImage(url: URL, cell: ReusableCell) {
        if url.isFileURL {
            loadLocalImage(url: url, cell: cell)
        } else {
            loadRemoteImage(url: url, cell: cell)
        }
    }
}

private extension CellImageLoader {
    func loadLocalImage(url: URL, cell: ReusableCell) {
        guard let imageData = try? Data(contentsOf: url),
              let image = UIImage(data: imageData) else {
            return
        }
        cell.imageView?.image = image
    }

    func loadRemoteImage(url: URL, cell: ReusableCell) {
        let uuid = imageLoader.loadImage(url: url) { [weak self] image in
            guard let self = self else { return image }
            return self.imageProcessors.reduce(image) { image, processor -> UIImage in
                processor.processImage(image)
            }
        } completion: { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(image):
                    cell.imageView?.image = image
                case .failure:
                    break
                }
            }
        }

        guard let cellUuid = uuid else { return }
        cell.onReuse = { [weak self] in
            self?.imageLoader.cancelImageLoad(uuid: cellUuid)
        }
    }
}
