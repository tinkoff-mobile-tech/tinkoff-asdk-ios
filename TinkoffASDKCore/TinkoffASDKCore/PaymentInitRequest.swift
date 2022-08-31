//
//  PaymentInitRequest.swift
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

///
/// Инициирует платёжную сессию и регистрирует заказ в системе Банка.
public final class PaymentInitRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    public var name = "Init"
    public var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    public var tokenParamsKey: Set<String> = [PaymentInitData.CodingKeys.amount.rawValue,
                                              PaymentInitData.CodingKeys.orderId.rawValue,
                                              PaymentInitData.CodingKeys.customerKey.rawValue,
                                              PaymentInitData.CodingKeys.savingAsParentPayment.rawValue]

    ///
    /// - Parameter data: `PaymentInitPaymentData`
    public init(data: PaymentInitData) {
        if let json = try? data.encode2JSONObject(dateEncodingStrategy: .iso8601) {
            parameters = json
        }
    }
}

///
public struct PaymentInitResponse: ResponseOperation {
    public var success: Bool
    public var errorCode: Int
    public var errorMessage: String?
    public var errorDetails: String?
    public var terminalKey: String?
    //
    public var amount: Int64
    public var orderId: String
    public var paymentId: Int64
    public var status: PaymentStatus

    private enum CodingKeys: String, CodingKey {
        case success = "Success"
        case errorCode = "ErrorCode"
        case errorMessage = "Message"
        case errorDetails = "Details"
        case terminalKey = "TerminalKey"
        //
        case amount = "Amount"
        case orderId = "OrderId"
        case paymentId = "PaymentId"
        case status = "Status"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        success = try container.decode(Bool.self, forKey: .success)
        errorCode = try Int(container.decode(String.self, forKey: .errorCode))!
        errorMessage = try? container.decode(String.self, forKey: .errorMessage)
        errorDetails = try? container.decode(String.self, forKey: .errorDetails)
        terminalKey = try? container.decode(String.self, forKey: .terminalKey)
        //
        amount = try container.decode(Int64.self, forKey: .amount)
        /// orderId
        orderId = try container.decode(String.self, forKey: .orderId)
        /// paymentId
        if let stringValue = try? container.decode(String.self, forKey: .paymentId), let value = Int64(stringValue) {
            paymentId = value
        } else {
            paymentId = try container.decode(Int64.self, forKey: .paymentId)
        }

        if let statusValue = try? container.decode(String.self, forKey: .status) {
            status = PaymentStatus(rawValue: statusValue)
        } else {
            status = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(success, forKey: .success)
        try container.encode(errorCode, forKey: .errorCode)
        try? container.encode(errorMessage, forKey: .errorMessage)
        try? container.encode(errorDetails, forKey: .errorDetails)
        //
        try container.encode(amount, forKey: .amount)
        try container.encode(orderId, forKey: .orderId)
        try container.encode(paymentId, forKey: .paymentId)
        try container.encode(status.rawValue, forKey: .status)
        try container.encode(terminalKey, forKey: .terminalKey)
    }
}

public struct PaymentInitResponseData {
    public let amount: Int64
    public let orderId: String
    public let paymentId: Int64

    public init(amount: Int64,
                orderId: String,
                paymentId: Int64)
    {
        self.amount = amount
        self.orderId = orderId
        self.paymentId = paymentId
    }

    public init(paymentInitResponse: PaymentInitResponse) {
        amount = paymentInitResponse.amount
        orderId = paymentInitResponse.orderId
        paymentId = paymentInitResponse.paymentId
    }
}
