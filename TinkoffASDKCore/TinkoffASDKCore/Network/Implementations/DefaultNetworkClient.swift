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
    private let requestBuilder: NetworkClientRequestBuilder
    private let responseValidator: HTTPURLResponseValidator
    
    var requestAdapter: NetworkRequestAdapter?
    
    // MARK: - Init
    
    init(urlRequestPerfomer: URLRequestPerformer,
         requestBuilder: NetworkClientRequestBuilder,
         responseValidator: HTTPURLResponseValidator) {
        self.urlRequestPerfomer = urlRequestPerfomer
        self.requestBuilder = requestBuilder
        self.responseValidator = responseValidator
    }
    
    // MARK: - NetworkClient
    
    @discardableResult
    func performRequest(_ request: NetworkRequest, completion: @escaping (NetworkResponse) -> Void) -> Cancellable {
        do {
            let urlRequest = try requestBuilder.buildURLRequest(request: request,
                                                                requestAdapter: requestAdapter)
            
            let dataTask = urlRequestPerfomer.createDataTask(with: urlRequest) { [responseValidator] data, response, error in
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
            }
            
            dataTask.resume()
            
            return dataTask
        } catch {
            handleFailedToBuildUrlRequest(error: error, completion: completion)
            return EmptyCancellable()
        }
    }
}

private extension DefaultNetworkClient {
    func handleFailedToBuildUrlRequest(error: Error, completion: @escaping (NetworkResponse) -> Void) {
        let response = NetworkResponse(request: nil,
                                       response: nil,
                                       error: nil,
                                       data: nil,
                                       result: .failure(error))
        completion(response)
    }
}
