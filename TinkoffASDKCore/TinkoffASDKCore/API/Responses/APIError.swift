//
//
//  APIError.swift
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

public enum APIError: LocalizedError, CustomNSError {
    case invalidResponse
    case failure(APIFailureError)

    // MARK: - CustomNSError

    public var errorCode: Int {
        switch self {
        case .invalidResponse:
            return 0
        case let .failure(apiFailureError):
            return apiFailureError.errorCode
        }
    }

    public var errorUserInfo: [String: Any] {
        guard let errorDescription = errorDescription else {
            return [:]
        }
        return [NSLocalizedDescriptionKey: errorDescription]
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return Loc.APIError.invalidResponse
        case let .failure(apiFailureError):
            return apiFailureError.errorDescription
        }
    }
}
