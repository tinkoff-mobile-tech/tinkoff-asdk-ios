//
//  YPPaymentSheet+Fake.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 20.04.2023.
//

import YandexPaySDK

extension YPPaymentSheet {

    static func fake() -> YPPaymentSheet {
        YPPaymentSheet(
            countryCode: .ru,
            currencyCode: .rub,
            order: .init(id: "123", amount: "123"),
            paymentMethods: [.card(.fake())]
        )
    }
}
