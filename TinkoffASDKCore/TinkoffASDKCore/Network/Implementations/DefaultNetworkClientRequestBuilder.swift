//
//
//  DefaultNetworkClientRequestBuilder.swift
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

final class DefaultNetworkClientRequestBuilder: NetworkClientRequestBuilder {
    
    enum Error: Swift.Error {
        case failedToBuildPath
    }
    
    // MARK: - NetworkClientRequestBuilder
    
    func buildURLRequest(baseURL: URL, request: NetworkRequest, requestAdapter: NetworkRequestAdapter?) throws -> URLRequest {
        let endpoint = request.path.joined(separator: "/")
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw Error.failedToBuildPath
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        
        var bodyParameters = request.bodyParameters
        var urlParameters = request.urlParameters
        var headers = request.headers
        
        if let requestAdapter = requestAdapter {
            bodyParameters.merge(requestAdapter.additionalBodyParameters(for: request)) { _, new in new }
            urlParameters.merge(requestAdapter.additionalURLParameters(for: request)) { _, new in new }
            headers.merge(requestAdapter.additionalHeaders(for: request)) { _, new in new }
        }
        
        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        return urlRequest
    }
    
    // MARK: - Parameters Encoding
    
    func encodeURLParameters(_ parameters: HTTPParameters, urlRequest: URLRequest) throws -> URLRequest {
        guard !parameters.keys.isEmpty else { return urlRequest }
        return urlRequest
    }
    
    func encodeJSONParameters(_ parameters: HTTPParameters, urlRequest: URLRequest) throws -> URLRequest {
        guard !parameters.keys.isEmpty else { return urlRequest }
        return urlRequest
    }
}
