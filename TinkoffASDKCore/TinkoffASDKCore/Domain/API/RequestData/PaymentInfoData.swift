//
//
//  PaymentInfoData.swift
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

@available(*, deprecated, renamed: "GetPaymentStateData")
public typealias PaymentInfoData = GetPaymentStateData

public struct GetPaymentStateData: Encodable {
    private enum CodingKeys: CodingKey {
        case paymentId

        var stringValue: String {
            switch self {
            case .paymentId:
                return APIConstants.Keys.paymentId
            }
        }
    }

    /// Номер заказа в системе Продавца
    let paymentId: String

    public init(paymentId: String) {
        self.paymentId = paymentId
    }

    @available(*, deprecated, message: "Use init(paymentId: String) instead")
    public init(paymentId: Int64) {
        self.paymentId = paymentId.description
    }
}
