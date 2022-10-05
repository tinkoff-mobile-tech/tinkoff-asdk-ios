//
//
//  APIFailureError.swift
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

public struct APIFailureError: LocalizedError, Decodable, CustomNSError {
    public let errorCode: Int
    public let errorMessage: String?
    public let errorDetails: String?
    public let terminalKey: String?
    public let status: String?
    public let orderId: String?
    public let paymentId: String?
    public let amount: Int?

    private enum CodingKeys: CodingKey {
        case errorCode
        case errorMessage
        case errorDetails
        case terminalKey
        case status
        case orderId
        case paymentId
        case amount

        var stringValue: String {
            switch self {
            case .errorCode: return APIConstants.Keys.errorCode
            case .errorDetails: return APIConstants.Keys.errorDetails
            case .errorMessage: return APIConstants.Keys.errorMessage
            case .terminalKey: return APIConstants.Keys.terminalKey
            case .status: return APIConstants.Keys.status
            case .orderId: return APIConstants.Keys.orderId
            case .paymentId: return APIConstants.Keys.paymentId
            case .amount: return APIConstants.Keys.amount
            }
        }
    }

    // MARK: - CustomNSError

    public var errorUserInfo: [String: Any] {
        guard let errorDescription = errorDescription else {
            return [:]
        }
        return [NSLocalizedDescriptionKey: errorDescription]
    }

    // MARK: - LocalizedError

    public var errorDescription: String? {
        var errorDescription = Loc.APIError.failureError
        if errorMessage != nil || errorDetails != nil { errorDescription += ": " }
        if let errorMessage = errorMessage {
            errorDescription += errorMessage
            if errorDetails != nil { errorDescription += " - " }
        }
        if let errorDetails = errorDetails {
            errorDescription += errorDetails
        }
        return errorDescription
    }

    // MARK: - Decodable

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let errorCodeString = try container.decode(String.self, forKey: .errorCode)
        errorCode = Int(errorCodeString) ?? 0
        errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
        errorDetails = try container.decodeIfPresent(String.self, forKey: .errorDetails)
        terminalKey = try container.decodeIfPresent(String.self, forKey: .terminalKey)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        orderId = try container.decodeIfPresent(String.self, forKey: .orderId)
        paymentId = try container.decodeIfPresent(String.self, forKey: .paymentId)
        amount = try container.decodeIfPresent(Int.self, forKey: .amount)
    }
}
