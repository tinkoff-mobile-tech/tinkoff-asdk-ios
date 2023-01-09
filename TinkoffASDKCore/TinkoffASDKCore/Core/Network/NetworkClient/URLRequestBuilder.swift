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
        case parametersEncodingFailed(error: Swift.Error)
    }

    // MARK: IURLRequestBuilder

    func build(request: NetworkRequest) throws -> URLRequest {
        let fullURL = try URL(string: request.path, relativeTo: request.baseURL).orThrow(Error.failedToBuildPath)

        var urlRequest = URLRequest(url: fullURL)
        urlRequest.httpMethod = request.httpMethod.rawValue
        request.headers.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        if request.httpMethod.isAllowedToContainBody, !request.parameters.isEmpty {
            switch request.parametersEncoding {
            case .json:
                try encodeJSON(with: request.parameters, into: &urlRequest)
            case .urlEncodedForm:
                try encodeURLForm(with: request.parameters, into: &urlRequest)
            }
        }

        return urlRequest
    }
}

// MARK: - JSON Parameters Encoding

private extension URLRequestBuilder {
    func encodeJSON(with parameters: HTTPParameters, into urlRequest: inout URLRequest) throws {
        urlRequest.httpBody = try Result {
            try JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys)
        }
        .mapError { Error.parametersEncodingFailed(error: $0) }
        .get()

        urlRequest.setContentTypeValueIfNeeded(.applicationJSON)
    }
}

// MARK: - URLEncodedForm Parameters Encoding

private extension URLRequestBuilder {
    enum URLEncodedFormError: Swift.Error {
        case failedToEncode(string: String)
    }

    func encodeURLForm(with parameters: HTTPParameters, into urlRequest: inout URLRequest) throws {
        let allowedCharacters = CharacterSet(charactersIn: " \"#%/:<>?@[\\]^`{|}+=").inverted

        let bodyString = parameters
            .sorted { $0.key < $1.key }
            .map { key, value in
                let value = "\(value)".addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? value
                return "\(key)=\(value)"
            }.joined(separator: "&")

        urlRequest.httpBody = try Result {
            try bodyString.data(using: .utf8).orThrow(URLEncodedFormError.failedToEncode(string: bodyString))
        }
        .mapError { Error.parametersEncodingFailed(error: $0) }
        .get()

        urlRequest.setContentTypeValueIfNeeded(.applicationFormUrlEncoded)
    }
}

// MARK: - Constants

private extension String {
    static let contentType = "Content-Type"
    static let applicationJSON = "application/json"
    static let applicationFormUrlEncoded = "application/x-www-form-urlencoded"
}

// MARK: - URLRequest + Utils

private extension URLRequest {
    mutating func setContentTypeValueIfNeeded(_ contentTypeValue: String) {
        guard value(forHTTPHeaderField: .contentType) == nil else { return }
        setValue(contentTypeValue, forHTTPHeaderField: .contentType)
    }
}
