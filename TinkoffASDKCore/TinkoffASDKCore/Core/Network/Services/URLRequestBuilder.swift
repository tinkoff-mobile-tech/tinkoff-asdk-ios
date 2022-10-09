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

protocol IURLRequestBuilder {
    func build(request: NetworkRequest) throws -> URLRequest
}

final class URLRequestBuilder: IURLRequestBuilder {
    // MARK: Error

    enum Error: Swift.Error {
        case failedToBuildPath
        case encodingFailed(error: Swift.Error)
    }

    // MARK: IURLRequestBuilder

    func build(request: NetworkRequest) throws -> URLRequest {
        let fullURL = try URL(string: request.path, relativeTo: request.baseURL)
            .orThrow(Error.failedToBuildPath)

        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = request.httpMethod.rawValue
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        if request.httpMethod != .get {
            try encodeJSON(with: request.parameters, toURLRequest: &urlRequest)
        }

        return urlRequest
    }

    // MARK: Encoding

    private func encodeJSON(
        with parameters: HTTPParameters,
        toURLRequest urlRequest: inout URLRequest
    ) throws {
        guard !parameters.isEmpty else { return }

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
        } catch {
            throw Error.encodingFailed(error: error)
        }

        urlRequest.setValue(.applicationJSON, forHTTPHeaderField: .contentType)
    }
}

// MARK: - Constants

private extension String {
    static let contentType = "Content-Type"
    static let applicationJSON = "application/json"
}
