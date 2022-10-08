//
//  AcquiringResponse.swift
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

public protocol ResponseOperation: Codable {
    var success: Bool { get }
    var errorCode: Int { get }
    var errorMessage: String? { get }
    var errorDetails: String? { get }
    var terminalKey: String? { get }
}

public class AcquiringResponse: ResponseOperation {
    private enum CodingKeys: CodingKey {
        case success
        case errorCode
        case errorMessage
        case errorDetails
        case terminalKey
        case status
        case paymentId
        case orderId
        case amount

        var stringValue: String {
            switch self {
            case .success: return Constants.Keys.success
            case .errorCode: return Constants.Keys.errorCode
            case .errorMessage: return Constants.Keys.errorMessage
            case .errorDetails: return Constants.Keys.errorDetails
            case .terminalKey: return Constants.Keys.terminalKey
            case .status: return Constants.Keys.status
            case .paymentId: return Constants.Keys.paymentId
            case .orderId: return Constants.Keys.orderId
            case .amount: return Constants.Keys.amount
            }
        }
    }

    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    public let status: String?
    public let paymentId: String?
    public let orderId: String?
    public let amount: Int?

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        status = try? container.decode(String.self, forKey: .status)
        paymentId = try? container.decode(String.self, forKey: .paymentId)
        orderId = try? container.decode(String.self, forKey: .orderId)
        amount = try? container.decode(Int.self, forKey: .amount)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try? container.encode(terminalKey, forKey: .terminalKey)
        try? container.encode(status, forKey: .status)
        try? container.encode(paymentId, forKey: .paymentId)
        try? container.encode(orderId, forKey: .orderId)
        try? container.encode(amount, forKey: .amount)
    }
}
