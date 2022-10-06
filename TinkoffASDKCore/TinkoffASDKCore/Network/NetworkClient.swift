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

    private let session: INetworkSession
    private let requestBuilder: IURLRequestBuilder
    private let responseValidator: IHTTPURLResponseValidator

    // MARK: Init

    init(
        session: INetworkSession,
        requestBuilder: IURLRequestBuilder,
        responseValidator: IHTTPURLResponseValidator
    ) {
        self.session = session
        self.requestBuilder = requestBuilder
        self.responseValidator = responseValidator
    }

    // MARK: INetworkClient

    @discardableResult
    func performRequest(_ request: NetworkRequest, completion: @escaping (NetworkResponse) -> Void) -> Cancellable {
        let urlRequest: URLRequest

        do {
            urlRequest = try requestBuilder.build(request: request)
        } catch {
            completion(.requestBuildingFailure(error: error))
            return EmptyCancellable()
        }

        let networkTask = createNetworkTask(with: urlRequest, completion: completion)
        networkTask.resume()
        return networkTask
    }

    // MARK: NetworkTask Creation

    private func createNetworkTask(with urlRequest: URLRequest, completion: @escaping (NetworkResponse) -> Void) -> INetworkDataTask {
        session.dataTask(with: urlRequest) { [responseValidator] data, response, error in
            let result = Result<Data, Error> {
                if let error = error {
                    throw NetworkError.transportError(error)
                }

                let httpResponse = try (response as? HTTPURLResponse).orThrow(NetworkError.noData)
                try responseValidator.validate(response: httpResponse)

                return try data.orThrow(NetworkError.noData)
            }

            let response = NetworkResponse(
                request: urlRequest,
                response: response as? HTTPURLResponse,
                error: error,
                data: data,
                result: result
            )

            completion(response)
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
}
