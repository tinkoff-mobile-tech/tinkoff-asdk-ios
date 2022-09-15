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

    @discardableResult
    @available(*, deprecated, message: "Use performRequest(_:completion:) instead")
    func performDeprecatedRequest<Response: ResponseOperation>(_ request: NetworkRequest, delegate: NetworkTransportResponseDelegate?, completion: @escaping (Result<Response, Error>) -> Void) -> Cancellable {
        do {
            let urlRequest = try requestBuilder.buildURLRequest(request: request,
                                                                requestAdapter: requestAdapter)
            let dataTask = urlRequestPerfomer.createDataTask(with: urlRequest) { data, response, error in
                if let error = error {
                    return completion(.failure(error))
                }

                // HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completion(.failure(NSError(domain: "Response should be an HTTPURLResponse", code: 1, userInfo: nil)))
                }

                // httpResponse check  HTTP Status Code `200..<300`
                guard httpResponse.isSuccessful else {
                    let error = HTTPResponseError(body: data, response: httpResponse, kind: .errorResponse)
                    completion(.failure(error))
                    return
                }

                // data is empty
                guard let data = data else {
                    let error = HTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse)
                    completion(.failure(error))
                    return
                }

                // delegating decode response data
                if let delegate = delegate {
                    guard let delegatedResponse = try? delegate.networkTransport(
                        didCompleteRawTaskForRequest: urlRequest,
                        withData: data,
                        response: httpResponse,
                        error: error
                    ) else {
                        let error = HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
                        completion(.failure(error))
                        return
                    }

                    completion(.success(delegatedResponse as! Response))
                    return
                }

                // decode as a default `AcquiringResponse`
                guard let acquiringResponse = try? JSONDecoder().decode(AcquiringResponse.self, from: data) else {
                    let error = HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)
                    completion(.failure(error))
                    return
                }

                // data  in `AcquiringResponse` format but `Success = 0;` ( `false` )
                guard acquiringResponse.success else {
                    var errorMessage: String = NSLocalizedString("TinkoffAcquiring.response.error.statusFalse", tableName: nil, bundle: .coreResources,
                                                                 comment: "Acquiring Error Response 'Success: false'")
                    if let message = acquiringResponse.errorMessage {
                        errorMessage = message
                    }

                    if let details = acquiringResponse.errorDetails, details.isEmpty == false {
                        errorMessage.append(contentsOf: " ")
                        errorMessage.append(contentsOf: details)
                    }

                    let error = NSError(domain: errorMessage,
                                        code: acquiringResponse.errorCode,
                                        userInfo: try? acquiringResponse.encode2JSONObject())

                    completion(.failure(error))
                    return
                }

                // decode to `Response`
                if let responseObject: Response = try? JSONDecoder().decode(Response.self, from: data) {
                    completion(.success(responseObject))
                } else {
                    completion(.failure(HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)))
                }
            }

            dataTask.resume()

            return dataTask
        } catch {
            completion(.failure(error))
            return EmptyCancellable()
        }
    }

    @discardableResult
    @available(*, deprecated, message: "Use performRequest(_:completion:) instead")
    func sendCertsConfigRequest(
        _ request: NetworkRequest,
        completionHandler: @escaping (Result<GetCertsConfigResponse, Error>) -> Void
    ) -> Cancellable  {
        do {
            let urlRequest = try requestBuilder.buildURLRequest(request: request,
                                                                requestAdapter: requestAdapter)
            
            let task = urlRequestPerfomer.createDataTask(with: urlRequest) { data, response, networkError in
                if let error = networkError {
                    return completionHandler(.failure(error))
                }
                
                // HTTPURLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    return completionHandler(.failure(NSError(domain: "Response should be an HTTPURLResponse", code: 1, userInfo: nil)))
                }
                
                // httpResponse check  HTTP Status Code `200..<300`
                guard httpResponse.isSuccessful else {
                    let error = HTTPResponseError(body: data, response: httpResponse, kind: .errorResponse)
                    completionHandler(.failure(error))
                    return
                }
                
                // data is empty
                guard let data = data else {
                    let error = HTTPResponseError(body: nil, response: httpResponse, kind: .invalidResponse)
                    completionHandler(.failure(error))
                    return
                }
                
                // decode to `Response`
                if let responseObject = try? JSONDecoder.customISO8601Decoding.decode(GetCertsConfigResponse.self, from: data) {
                    completionHandler(.success(responseObject))
                } else {
                    completionHandler(.failure(HTTPResponseError(body: data, response: httpResponse, kind: .invalidResponse)))
                }
            } // session.dataTask
            
            task.resume()
            
            return task
        } catch {
            completionHandler(.failure(error))
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
