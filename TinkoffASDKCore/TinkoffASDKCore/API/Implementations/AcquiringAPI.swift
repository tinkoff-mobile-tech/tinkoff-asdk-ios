//
//
//  AcquiringAPI.swift
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

final class AcquiringAPI: API {
    private let networkClient: NetworkClient
    private let apiResponseDecoder: APIResponseDecoder
    
    init(networkClient: NetworkClient,
         apiResponseDecoder: APIResponseDecoder) {
        self.networkClient = networkClient
        self.apiResponseDecoder = apiResponseDecoder
    }
    
    // MARK: - API

    func performRequest<Request: APIRequest>(_ request: Request,
                                             completion: @escaping (Swift.Result<Request.Payload, Error>) -> Void) -> Cancellable {
        return networkClient.performRequest(request) { [weak self] response in
            do {
                let data = try response.result.get()
                self?.handleResponseData(data,
                                         for: request,
                                         completion: completion)
            } catch {
                completion(.failure(error))
            }
        }
    }
}

private extension AcquiringAPI {
    func handleResponseData<Request: APIRequest>(_ data: Data,
                                                 for request: Request,
                                                 completion: @escaping (Swift.Result<Request.Payload, Error>) -> Void) {
        do {
            let apiResponse = try apiResponseDecoder.decode(data: data, for: request)
            let payload = try apiResponse.result.get()
            completion(.success(payload))
        } catch let apiFailureError as APIFailureError {
            completion(.failure(APIError.failure(apiFailureError)))
        } catch {
            completion(.failure(APIError.invalidResponse))
        }
    }
}
