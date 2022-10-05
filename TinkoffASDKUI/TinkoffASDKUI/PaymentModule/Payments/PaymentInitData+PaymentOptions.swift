//
//
//  PaymentInitData+PaymentOptions.swift
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

import TinkoffASDKCore

extension PaymentInitData {
    static func data(
        with paymentOptions: PaymentOptions,
        isCharge: Bool = false
    ) -> PaymentInitData {
        let orderOptions = paymentOptions.orderOptions
        let customerOptions = paymentOptions.customerOptions

        let customerKey: String?
        switch customerOptions.customer {
        case let .customer(key, _):
            customerKey = key
        case .none:
            customerKey = nil
        }

        var initData = PaymentInitData(
            amount: orderOptions.amount,
            orderId: orderOptions.orderId,
            customerKey: customerKey
        )

        initData.description = orderOptions.description
        initData.savingAsParentPayment = orderOptions.savingAsParentPayment
        initData.receipt = orderOptions.receipt
        initData.shops = orderOptions.shops
        initData.receipts = orderOptions.receipts

        if isCharge {
            initData.addPaymentData(["chargeFlag": "true"])
        }

        if let failedPaymentId = paymentOptions.failedPaymentId {
            initData.addPaymentData(["failMapiSessionId": "\(failedPaymentId)"])
            initData.addPaymentData(["recurringType": "12"])
        }

        if let paymentData = paymentOptions.paymentData {
            initData.addPaymentData(paymentData)
        }

        return initData
    }
}
