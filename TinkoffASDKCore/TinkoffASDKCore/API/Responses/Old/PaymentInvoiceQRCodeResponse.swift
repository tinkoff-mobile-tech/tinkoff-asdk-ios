//
//
//  PaymentInvoiceQRCodeResponse.swift
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

public struct PaymentInvoiceQRCodeResponse: ResponseOperation {
    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case orderId = "OrderId"
        case paymentId = "PaymentId"
        case qrCodeData = "Data"

        var stringValue: String {
            switch self {
            case .success: return APIConstants.Keys.success
            case .errorCode: return APIConstants.Keys.errorCode
            case .errorMessage: return APIConstants.Keys.errorMessage
            case .errorDetails: return APIConstants.Keys.errorDetails
            case .terminalKey: return APIConstants.Keys.terminalKey
            case .orderId: return APIConstants.Keys.orderId
            case .paymentId: return APIConstants.Keys.paymentId
            case .qrCodeData: return APIConstants.Keys.qrCodeData
            }
        }
    }

    // MARK: AcquiringResponseProtocol

    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?

    // MARK: PaymentInvoice

    public var orderId: String
    public var paymentId: Int64
    public var qrCodeData: String

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)

        // orderId
        orderId = try container.decode(String.self, forKey: .orderId)

        // paymentId
        if let stringValue = try? container.decode(String.self, forKey: .paymentId), let value = Int64(stringValue) {
            paymentId = value
        } else {
            paymentId = try container.decode(Int64.self, forKey: .paymentId)
        }

        qrCodeData = try container.decode(String.self, forKey: .qrCodeData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        try container.encode(terminalKey, forKey: .terminalKey)
        //
        try container.encode(orderId, forKey: .orderId)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(qrCodeData, forKey: .qrCodeData)
    }
}
