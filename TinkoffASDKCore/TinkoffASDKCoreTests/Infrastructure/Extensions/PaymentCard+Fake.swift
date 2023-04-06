//
//  PaymentCard+Fake.swift
//  Pods
//
//  Created by Ivan Glushko on 28.03.2023.
//

import TinkoffASDKCore

extension PaymentCard {

    static func fake() -> Self {
        PaymentCard(
            pan: "34234",
            cardId: "123213",
            status: .active,
            parentPaymentId: 123,
            expDate: "0929"
        )
    }
}
