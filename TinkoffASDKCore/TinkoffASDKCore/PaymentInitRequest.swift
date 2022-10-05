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
    public var tokenParamsKey: Set<String> = [
        PaymentInitData.CodingKeys.amount.rawValue,
        PaymentInitData.CodingKeys.orderId.rawValue,
        PaymentInitData.CodingKeys.customerKey.rawValue,
        PaymentInitData.CodingKeys.savingAsParentPayment.rawValue,
    ]

    ///
    /// - Parameter data: `PaymentInitPaymentData`
    public init(data: PaymentInitData) {
        if let json = try? data.encode2JSONObject(dateEncodingStrategy: .iso8601) {
            parameters = json
        }
    }
}

@available(*, deprecated, message: "Will be removed soon")
public struct PaymentInitResponseData {
    public let amount: Int64
    public let orderId: String
    public let paymentId: Int64

    public init(
        amount: Int64,
        orderId: String,
        paymentId: Int64
    ) {
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
