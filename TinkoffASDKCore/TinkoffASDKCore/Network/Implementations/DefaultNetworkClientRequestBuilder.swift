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

    func buildURLRequest(request: NetworkRequest, requestAdapter: NetworkRequestAdapter?) throws -> URLRequest {
        let endpoint = request.path.joined(separator: "/")
        guard let url = URL(string: endpoint, relativeTo: request.baseURL) else {
            throw Error.failedToBuildPath
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue

        var parameters = request.parameters
        var headers = request.headers

        if let requestAdapter = requestAdapter {
            parameters.merge(requestAdapter.additionalParameters(for: request)) { _, new in new }
            headers.merge(requestAdapter.additionalHeaders(for: request)) { _, new in new }
        }

        headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        urlRequest = try encodeJSONParameters(
            parameters,
            parametersEncoding: request.parametersEncoding,
            urlRequest: urlRequest
        )

        return urlRequest
    }

    // MARK: - Parameters Encoding

    private func encodeJSONParameters(
        _ parameters: HTTPParameters,
        parametersEncoding: HTTPParametersEncoding,
        urlRequest: URLRequest
    ) throws -> URLRequest {
        guard !parameters.isEmpty else { return urlRequest }

        let encoder: ParametersEncoder
        switch parametersEncoding {
        case .json: encoder = JSONEncoding(options: .sortedKeys)
        }

        return try encoder.encode(urlRequest, parameters: parameters)
    }
}

protocol IRequestAdapter {
    func adapt(request: NetworkRequest, completion: @escaping (Result<NetworkRequest, Error>) -> Void)
}

final class RequestAdapter {
    func adapt(request: NetworkRequest, completion: @escaping (Result<NetworkRequest, Error>) -> Void) {}
}

final class URLRequestBuilder {
    private let requestAdapter: IRequestAdapter
    private let jsonEncoder: ParametersEncoder

    init(requestAdapter: IRequestAdapter, jsonEncoder: ParametersEncoder) {
        self.requestAdapter = requestAdapter
        self.jsonEncoder = jsonEncoder
    }

    func build(request: NetworkRequest, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        requestAdapter.adapt(request: request) { [self] adaptingResult in
            let urlRequestResult = adaptingResult.tryMap(build(from:))
            completion(urlRequestResult)
        }
    }

    private func build(from request: NetworkRequest) throws -> URLRequest {
        let fullURL = request
            .path
            .reduce(into: request.baseURL) { $0.appendingPathComponent($1) }

        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = request.httpMethod.rawValue
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        switch request.parametersEncoding {
        case .json:
            return try jsonEncoder.encode(urlRequest, parameters: request.parameters)
        }
    }
}
