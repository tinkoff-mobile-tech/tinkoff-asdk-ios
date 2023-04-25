//
//  YandexPayMethod+Fake.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 26.04.2023.
//

import TinkoffASDKCore

extension YandexPayMethod {

    static func fake() -> YandexPayMethod {
        YandexPayMethod(
            merchantId: "merchantId",
            merchantName: "merchantName",
            merchantOrigin: "merchantOrigin",
            showcaseId: "showcaseId"
        )
    }
}
