//
//
//  NetworkSession.swift
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

import Foundation

protocol INetworkSession {
    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> INetworkDataTask
}

final class NetworkSession: INetworkSession {
    // MARK: NetworkDataTask

    private final class NetworkDataTask: INetworkDataTask {
        private let dataTask: URLSessionDataTask

        init(dataTask: URLSessionDataTask) {
            self.dataTask = dataTask
        }

        func resume() {
            dataTask.resume()
        }

        func cancel() {
            dataTask.cancel()
        }
    }

    // MARK: Dependencies

    private let urlSession: URLSession

    // MARK: Init

    /// Инициализирует `NetworkSession`
    /// - Parameters:
    ///   - urlSession: `URLSession`
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    deinit {
        /// `URLSession` хранит сильную ссылку на делегат, инвалидируем сессию чтобы освободить память.
        /// The session object keeps a strong reference to the delegate
        /// until your app exits or explicitly invalidates the session
        self.urlSession.invalidateAndCancel()
    }

    // MARK: INetworkSession

    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> INetworkDataTask {
        return NetworkDataTask(dataTask: urlSession.dataTask(with: request, completionHandler: completion))
    }
}
