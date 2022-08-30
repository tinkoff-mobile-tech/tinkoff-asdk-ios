//
//
//  DefaultNetworkClient.swift
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

final class DefaultNetworkClient: NetworkClient {
    private let urlRequestPerfomer: URLRequestPerformer
    private let baseUrl: URL
    private let requestBuilder: NetworkClientRequestBuilder
    private let responseValidator: HTTPURLResponseValidator
    
    weak var requestAdapter: NetworkRequestAdapter?
    
    init(urlRequestPerfomer: URLRequestPerformer,
         baseUrl: URL,
         requestBuilder: NetworkClientRequestBuilder,
         responseValidator: HTTPURLResponseValidator) {
        self.urlRequestPerfomer = urlRequestPerfomer
        self.baseUrl = baseUrl
        self.requestBuilder = requestBuilder
        self.responseValidator = responseValidator
    }
    
    // MARK: NetworkClient
    
    func performRequest(_ request: NetworkRequest, completion: @escaping (NetworkResponse) -> Void) {
        do {
            let urlRequest = try requestBuilder.buildURLRequest(baseURL: baseUrl,
                                                                request: request,
                                                                requestAdapter: requestAdapter)
            urlRequestPerfomer.dataTask(with: urlRequest) { [responseValidator] data, response, error in
                let result: Result<Data, Error>
                
                defer {
                    let response = NetworkResponse(request: urlRequest,
                                                   response: response as? HTTPURLResponse,
                                                   error: error,
                                                   data: data,
                                                   result: result)
                    completion(response)
                }
                
                if let error = error {
                    result = .failure(NetworkError.transportError(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    // TODO: Handle this case
                    result = .failure(NetworkError.noData)
                    return
                }
                
                do {
                    try responseValidator.validate(response: httpResponse).get()
                } catch {
                    result = .failure(NetworkError.serverError(statusCode: httpResponse.statusCode,
                                                               data: data))
                    return
                }
                
                guard let data = data else {
                    result = .failure(NetworkError.noData)
                    return
                }
                
                result = .success(data)
            }.resume()
        } catch {
            handleFailedToBuildeUrlRequest(error: error, completion: completion)
        }
    }
    
    private func handleFailedToBuildeUrlRequest(error: Error, completion: @escaping (NetworkResponse) -> Void) {
        let response = NetworkResponse(request: nil,
                                       response: nil,
                                       error: nil,
                                       data: nil,
                                       result: .failure(error))
        completion(response)
    }
}
