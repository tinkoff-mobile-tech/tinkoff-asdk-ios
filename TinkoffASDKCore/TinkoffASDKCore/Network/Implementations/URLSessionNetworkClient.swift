//
//
//  URLSessionNetworkClient.swift
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

final class URLSessionNetworkClient: NetworkClient {
    private let urlSession: URLSession
    private let baseUrl: URL
    private let requestBuilder: NetworkClientRequestBuilder
    
    weak var requestAdapter: NetworkRequestAdapter?
    
    init(urlSession: URLSession,
         baseUrl: URL,
         requestBuilder: NetworkClientRequestBuilder) {
        self.urlSession = urlSession
        self.baseUrl = baseUrl
        self.requestBuilder = requestBuilder
    }
    
    // MARK: NetworkClient
    
    func performRequest(_ request: NetworkRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let urlRequest = try requestBuilder.buildURLRequest(baseURL: baseUrl,
                                                            request: request,
                                                            requestAdapter: requestAdapter)
            urlSession.dataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(data ?? Data()))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
}
