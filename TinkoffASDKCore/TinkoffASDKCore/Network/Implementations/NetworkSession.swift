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
    func createDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NetworkDataTask
}

final class NetworkSession: INetworkSession {
    private let urlSession: URLSession
    /// Реализует протокол делегата `URLSession`. 
    /// Удерживается данным классом, поскольку `URLSession` хранит слабую ссылку на свой делегат 
    private let sessionDelegate: URLSessionDelegate

    init(urlSession: URLSession, sessionDelegate: URLSessionDelegate) {
        self.urlSession = urlSession
        self.sessionDelegate = sessionDelegate
    }

    func createDataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> NetworkDataTask {
        urlSession.dataTask(with: request, completionHandler: completionHandler)
    }
}
