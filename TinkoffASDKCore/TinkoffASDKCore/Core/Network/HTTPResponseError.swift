//
//  AcquaringNetworkTransport.swift
//  TinkoffASDKCore
//
//  Copyright (c) 2020 Tinkoff Bank
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

public struct HTTPResponseError: Error, LocalizedError {
    private let serializationFormat = JSONSerializationFormat.self

    public enum ErrorKind {
        case errorResponse
        case invalidResponse

        var description: String {
            switch self {
            case .errorResponse:
                return "Received error response"
            case .invalidResponse:
                return "Received invalid response"
            }
        }
    }

    public let body: Data?
    public let response: HTTPURLResponse
    public let kind: ErrorKind

    public init(body: Data? = nil, response: HTTPURLResponse, kind: ErrorKind) {
        self.body = body
        self.response = response
        self.kind = kind
    }

    public var bodyDescription: String {
        guard let body = body else {
            return "Empty response body"
        }

        guard let description = String(data: body, encoding: response.textEncoding ?? .utf8) else {
            return "Unreadable response body"
        }

        return description
    }

    // MARK: LocalizedError

    public var errorDescription: String? {
        return "\(kind.description) (\(response.statusCode) \(response.statusCodeDescription)): \(bodyDescription)"
    }
}

// MARK: - Helpers

private extension HTTPURLResponse {
    var statusCodeDescription: String {
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }

    var textEncoding: String.Encoding? {
        guard let encodingName = textEncodingName else { return nil }

        return String.Encoding(
            rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding(encodingName as CFString))
        )
    }
}
