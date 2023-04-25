//
//  YPPaymentInfo+Fake.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 20.04.2023.
//

import YandexPaySDK

extension YPPaymentInfo {

    static func fake() -> YPPaymentInfo {
        YPPaymentInfo(
            paymentToken: "YPPaymentToken",
            paymentMethodInfo: .card(.init(cardLast4: "2344", cardNetwork: .mir)),
            paymentAmount: "200"
        )
    }
}
