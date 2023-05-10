//
//  YPCardPaymentMethod+Fake.swift
//  Pods-ASDKSample
//
//  Created by Ivan Glushko on 20.04.2023.
//

import YandexPaySDK

extension YPCardPaymentMethod {

    static func fake() -> YPCardPaymentMethod {
        YPCardPaymentMethod(
            gateway: "YPGateway",
            gatewayMerchantId: "gatewayMerchantId",
            allowedAuthMethods: [.panOnly],
            allowedCardNetworks: [.mir]
        )
    }
}
