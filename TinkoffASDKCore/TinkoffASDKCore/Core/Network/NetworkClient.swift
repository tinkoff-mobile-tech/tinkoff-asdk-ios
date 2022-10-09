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

// MARK: - NetworkResponse

struct NetworkResponse {
    let urlRequest: URLRequest
    let httpResponse: HTTPURLResponse
    let data: Data
}

// MARK: - NetworkError

enum NetworkError: Error {
    case failedToBuildURLRequest(Error)
    case sessionError(Error)
    case incorrectResponse
}

// MARK: - INetworkClient

protocol INetworkClient: AnyObject {
    @discardableResult
    func performRequest(_ request: NetworkRequest, completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void) -> Cancellable
}

// MARK: - NetworkClient

final class NetworkClient: INetworkClient {
    // MARK: Error

//    private enum Error: LocalizedError, CustomNSError {
//        case sessionError(Swift.Error)
//        case noDataFound
//
//        var errorDescription: String? {
//            let description: String
//            switch self {
//            case let .sessionError(error):
//                description = "\(Loc.NetworkError.transportError): \(error.localizedDescription)"
//            case .noDataFound:
//                description = "\(Loc.NetworkError.emptyBody)"
//            }
//            return description
//        }
//    }

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
    func performRequest(
        _ request: NetworkRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> Cancellable {
        let urlRequest: URLRequest

        do {
            urlRequest = try requestBuilder.build(request: request)
        } catch {
            completion(.failure(.failedToBuildURLRequest(error)))
            return EmptyCancellable()
        }

        let networkTask = createNetworkTask(with: urlRequest, completion: completion)
        networkTask.resume()
        return networkTask
    }

    // MARK: NetworkTask Creation

    private func createNetworkTask(
        with urlRequest: URLRequest,
        completion: @escaping (Result<NetworkResponse, NetworkError>) -> Void
    ) -> INetworkDataTask {
        session.dataTask(with: urlRequest) { [responseValidator] data, response, error in
            let result: Result<NetworkResponse, NetworkError>
            defer { completion(result) }

            if let error = error {
                result = .failure(.sessionError(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                result = .failure(.incorrectResponse)
                return
            }

            do {
                try responseValidator.validate(response: httpResponse)
            } catch {
                result = .failure(.incorrectResponse)
                return
            }

            guard let data = data else {
                result = .failure(.incorrectResponse)
                return
            }

            let networkResponse = NetworkResponse(urlRequest: urlRequest, httpResponse: httpResponse, data: data)
            result = .success(networkResponse)
        }
    }
}
