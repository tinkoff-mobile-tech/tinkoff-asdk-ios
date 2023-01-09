//
//
//  ImageLoader.swift
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

import TinkoffASDKCore
import UIKit

final class ImageLoader {

    enum Error: Swift.Error {
        case failedToLoadImage
    }

    private let urlDataLoader: AcquiringSdk
    private let cache = NSCache<NSURL, UIImage>()
    private var requests = [UUID: Cancellable]()

    init(urlDataLoader: AcquiringSdk) {
        self.urlDataLoader = urlDataLoader
    }

    func loadImage(
        url: URL,
        preCacheClosure: @escaping (UIImage) -> UIImage,
        completion: @escaping (Result<UIImage, Swift.Error>) -> Void
    ) -> UUID? {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(.success(cachedImage))
            return nil
        }

        let uuid = UUID()

        let task = urlDataLoader.loadData(with: url) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(data):
                guard var image = UIImage(data: data) else {
                    return completion(.failure(Error.failedToLoadImage))
                }

                image = preCacheClosure(image)
                self.cache.setObject(image, forKey: url as NSURL)
                completion(.success(image))
            case let .failure(error as NSError) where error.code == NSURLErrorCancelled:
                break
            case let .failure(error):
                completion(.failure(error))
            }
        }

        requests[uuid] = task

        return uuid
    }

    func cancelImageLoad(uuid: UUID) {
        requests[uuid]?.cancel()
        requests.removeValue(forKey: uuid)
    }
}
