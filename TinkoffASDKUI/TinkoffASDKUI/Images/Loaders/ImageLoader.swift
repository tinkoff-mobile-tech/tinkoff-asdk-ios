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


import UIKit

final class ImageLoader {
    
    enum Error: Swift.Error {
        case failedToLoadImage
    }
    
    private let cache = NSCache<NSURL, UIImage>()
    private var requests = [UUID: URLSessionDataTask]()
    
    func loadImage(url: URL,
                   preCacheClosure: @escaping (UIImage) -> UIImage,
                   completion: @escaping (Result<UIImage, Swift.Error>) -> Void) -> UUID? {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            completion(.success(cachedImage))
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            guard error == nil else {
                self.handleError(error!, completion: completion)
                return
            }
            
            guard let data = data, var image = UIImage(data: data) else {
                completion(.failure(Error.failedToLoadImage))
                return
            }
            
            image = preCacheClosure(image)
            self.cache.setObject(image, forKey: url as NSURL)
            completion(.success(image))
        }
        
        task.resume()
        requests[uuid] = task
        
        return uuid
    }
    
    func cancelImageLoad(uuid: UUID) {
        requests[uuid]?.cancel()
        requests.removeValue(forKey: uuid)
    }
}

private extension ImageLoader {
    func handleError(_ error: Swift.Error, completion: (Result<UIImage, Swift.Error>) -> Void) {
        switch (error as NSError).code {
        case NSURLErrorCancelled:
            break
        default:
            completion(.failure(error))
        }
    }
}
