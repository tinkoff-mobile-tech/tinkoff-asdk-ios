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
    func performRequest(_ request: NetworkRequest, completion: @escaping (NetworkResponse) -> Void) -> Cancellable
}

final class NetworkClient: INetworkClient {
    // MARK: Dependencies

    private let requestAdapter: IRequestAdapter
    private let requestBuilder: IURLRequestBuilder
    private let urlRequestPerformer: URLRequestPerformer
    private let responseValidator: HTTPURLResponseValidator

    // MARK: Init

    init(
        requestAdapter: IRequestAdapter,
        requestBuilder: IURLRequestBuilder,
        urlRequestPerformer: URLRequestPerformer,
        responseValidator: HTTPURLResponseValidator
    ) {
        self.requestAdapter = requestAdapter
        self.requestBuilder = requestBuilder
        self.urlRequestPerformer = urlRequestPerformer
        self.responseValidator = responseValidator
    }

    // MARK: INetworkClient

    @discardableResult
    func performRequest(_ request: NetworkRequest, completion: @escaping (NetworkResponse) -> Void) -> Cancellable {
        let taskHolder = NetworkTaskHolder()

        requestAdapter.adapt(request: request) { [self] adaptingResult in
            let urlRequestResult = adaptingResult.tryMap(requestBuilder.build(request:))

            switch urlRequestResult {
            case let .success(urlRequest):
                let networkTask = createNetworkTask(with: urlRequest, completion: completion)
                if taskHolder.store(networkTask) {
                    networkTask.resume()
                }
            case let .failure(error):
                completion(.requestBuildingFailure(error: error))
            }
        }

        return taskHolder
    }

    // MARK: NetworkTask Creation

    private func createNetworkTask(with urlRequest: URLRequest, completion: @escaping (NetworkResponse) -> Void) -> NetworkDataTask {
        urlRequestPerformer.createDataTask(with: urlRequest) { [responseValidator] data, response, error in
            let result = Result<Data, Error> {
                if let error = error {
                    throw NetworkError.transportError(error)
                }

                let httpResponse = try (response as? HTTPURLResponse).orThrow(NetworkError.noData)

                try responseValidator
                    .validate(response: httpResponse)
                    .mapError { _ in NetworkError.serverError(statusCode: httpResponse.statusCode, data: data) }
                    .get()

                return try data.orThrow(NetworkError.noData)
            }

            completion(
                .executionStatus(
                    request: urlRequest,
                    response: response,
                    error: error, data: data,
                    result: result
                )
            )
        }
    }
}

// MARK: - NetworkResponse + Mapping

private extension NetworkResponse {
    static func requestBuildingFailure(error: Error) -> NetworkResponse {
        NetworkResponse(
            request: nil,
            response: nil,
            error: nil,
            data: nil,
            result: .failure(error)
        )
    }

    static func executionStatus(
        request: URLRequest,
        response: URLResponse?,
        error: Error?,
        data: Data?,
        result: Result<Data, Error>
    ) -> NetworkResponse {
        NetworkResponse(
            request: request,
            response: response as? HTTPURLResponse,
            error: error,
            data: data,
            result: result
        )
    }
}
