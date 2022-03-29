//
//  PaymentChargeRequest.swift
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
public struct PaymentChargeRequestData: Codable {
    /// Номер заказа в системе Продавца
    public var paymentId: Int64
    /// Родительский платеж
    public var parentPaymentId: Int64

    public init(paymentId: Int64, parentPaymentId: Int64) {
        self.paymentId = paymentId
        self.parentPaymentId = parentPaymentId
    }

    public enum CodingKeys: String, CodingKey {
        case paymentId = "PaymentId"
        case parentPaymentId = "RebillId"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        paymentId = try container.decode(Int64.self, forKey: .paymentId)
        parentPaymentId = try container.decode(Int64.self, forKey: .parentPaymentId)
    }
}

class PaymentChargeRequest: RequestOperation, AcquiringRequestTokenParams {
    // MARK: RequestOperation

    var name: String = "Charge"

    var parameters: JSONObject?

    // MARK: AcquiringRequestTokenParams

    ///
    /// отмечаем параметры которые участвуют в вычислении `token`
    var tokenParamsKey: Set<String> = [
        PaymentChargeRequestData.CodingKeys.paymentId.rawValue,
        PaymentChargeRequestData.CodingKeys.parentPaymentId.rawValue
    ]

    ///
    /// - Parameter data: `FinishRequestData`
    init(data: PaymentChargeRequestData) {
        if let json = try? data.encode2JSONObject() {
            self.parameters = json
        }
    }
}
