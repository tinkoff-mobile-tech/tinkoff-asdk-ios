//
//
//  NetworkClient.swift
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

protocol INetworkClient: AnyObject {
    @discardableResult
    func performRequest(
        _ request: NetworkRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable

    @discardableResult
    func performRequest(
        _ urlRequest: URLRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable
}

final class NetworkClient: INetworkClient {
    // MARK: Dependencies

    private let session: INetworkSession
    private let requestBuilder: IURLRequestBuilder
    private let statusCodeValidator: IHTTPStatusCodeValidator

    // MARK: Init

    init(
        session: INetworkSession,
        requestBuilder: IURLRequestBuilder,
        statusCodeValidator: IHTTPStatusCodeValidator
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.statusCodeValidator = statusCodeValidator
    }

    // MARK: INetworkClient

    @discardableResult
    func performRequest(
        _ request: NetworkRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable {
        let urlRequest: URLRequest

        do {
            urlRequest = try requestBuilder.build(request: request)
        } catch {
            completion(.failure(.failedToCreateRequest(error)))
            return EmptyCancellable()
        }

        return performRequest(urlRequest, completion: completion)
    }

    @discardableResult
    func performRequest(
        _ urlRequest: URLRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable {
        let networkTask = session.dataTask(with: urlRequest) { [statusCodeValidator] data, response, error in
            let result: Result<NetworkResponse, NetworkError>
            defer { completion(result) }

            if let error = error {
                result = .failure(.transportError(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.emptyResponse)
                return
            }

            guard statusCodeValidator.validate(statusCode: httpResponse.statusCode) else {
                result = .failure(.serverError(statusCode: httpResponse.statusCode))
                return
            }

            guard let data = data else {
                result = .failure(.emptyResponse)
                return
            }

            let networkResponse = NetworkResponse(
                urlRequest: urlRequest,
                httpResponse: httpResponse,
                data: data
            )

            result = .success(networkResponse)
        }

        networkTask.resume()
        return networkTask
    }
}
