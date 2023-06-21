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

    static func sberFake() -> Self {
        PaymentCard(
            pan: "427432",
            cardId: "124913",
            status: .active,
            parentPaymentId: 123,
            expDate: "0929"
        )
    }
}

extension Array where Element == PaymentCard {

    /// Change with caution [snapshot image tests use this]
    static func fake() -> Self {
        [
            PaymentCard(
                pan: "427432",
                cardId: "124913",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "525787",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "419540",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "518901",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "510070",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "543762",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "342347",
                cardId: "123213",
                status: .active,
                parentPaymentId: 123,
                expDate: "0929"
            ),
            PaymentCard(
                pan: "34234",
                cardId: "123213",
                status: .inactive,
                parentPaymentId: 123,
                expDate: "0929"
            ),
        ]
    }
}
