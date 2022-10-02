//
//
//  NetworkError.swift
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

enum NetworkError: LocalizedError, CustomNSError {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData

    var errorCode: Int {
        switch self {
        case let .transportError(error):
            return (error as NSError).code
        case let .serverError(statusCode):
            return statusCode
        case .noData:
            return 0
        }
    }

    var errorDescription: String? {
        let description: String
        switch self {
        case let .transportError(error):
            description = "\(Loc.NetworkError.transportError): \(error.localizedDescription)"
        case let .serverError(statusCode):
            description = "\(Loc.NetworkError.serverError): \(statusCode)"
        case .noData:
            description = "\(Loc.NetworkError.emptyBody)"
        }
        return description
    }
}
