//
//  ChargeData.swift
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

public struct ChargeData: Encodable {
    private enum CodingKeys: CodingKey {
        case paymentId
        case rebillId

        var stringValue: String {
            switch self {
            case .paymentId: return APIConstants.Keys.paymentId
            case .rebillId: return APIConstants.Keys.rebillId
            }
        }
    }

    /// Номер заказа в системе Продавца
    public let paymentId: String
    /// Родительский платеж
    public let rebillId: String

    public init(paymentId: String, rebillId: String) {
        self.paymentId = paymentId
        self.rebillId = rebillId
    }
}

@available(*, deprecated, message: "Use `ChargeRequestData` instead")
public struct PaymentChargeRequestData: Encodable {
    private enum CodingKeys: CodingKey {
        case paymentId
        case parentPaymentId

        var stringValue: String {
            switch self {
            case .paymentId: return APIConstants.Keys.paymentId
            case .parentPaymentId: return APIConstants.Keys.rebillId
            }
        }
    }

    /// Номер заказа в системе Продавца
    public var paymentId: Int64
    /// Родительский платеж
    public var parentPaymentId: Int64

    public init(paymentId: Int64, parentPaymentId: Int64) {
        self.paymentId = paymentId
        self.parentPaymentId = parentPaymentId
    }
}
