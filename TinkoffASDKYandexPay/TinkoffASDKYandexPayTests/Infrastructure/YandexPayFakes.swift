//
//  Fakes.swift
//  TinkoffASDKYandexPay
//
//  Created by Никита Васильев on 07.08.2023.
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

extension YPPaymentInfo {

    static func fake() -> YPPaymentInfo {
        YPPaymentInfo(
            paymentToken: "YPPaymentToken",
            paymentMethodInfo: .card(.init(cardLast4: "2344", cardNetwork: .mir)),
            paymentAmount: "200",
            billingContact: nil
        )
    }
}

extension YPPaymentSheet: Equatable {
    public static func == (lhs: YandexPaySDK.YPPaymentSheet, rhs: YandexPaySDK.YPPaymentSheet) -> Bool {

        lhs.countryCode == rhs.countryCode &&
            lhs.currencyCode == rhs.currencyCode &&
            lhs.order == rhs.order &&
            lhs.paymentMethods == rhs.paymentMethods &&
            lhs.additionalFields == rhs.additionalFields &&
            lhs.requiredFields == rhs.requiredFields
    }
}

extension YPOrder: Equatable {
    public static func == (lhs: YandexPaySDK.YPOrder, rhs: YandexPaySDK.YPOrder) -> Bool {
        lhs.amount == rhs.amount &&
            lhs.id == rhs.id &&
            lhs.label == rhs.label
    }
}

extension YPPaymentMethod: Equatable {
    public static func == (lhs: YandexPaySDK.YPPaymentMethod, rhs: YandexPaySDK.YPPaymentMethod) -> Bool {
        switch lhs {
        case let .card(lhsMethod):
            guard case let .card(rhsMethod) = rhs else { return false }
            return lhsMethod == rhsMethod
        @unknown default:
            fatalError("Implement new ones")
        }
    }
}

extension YPCardPaymentMethod: Equatable {
    public static func == (lhs: YPCardPaymentMethod, rhs: YPCardPaymentMethod) -> Bool {
        lhs.gateway == rhs.gateway &&
            lhs.gatewayMerchantId == rhs.gatewayMerchantId &&
            lhs.allowedAuthMethods == rhs.allowedAuthMethods &&
            lhs.allowedCardNetworks == rhs.allowedCardNetworks &&
            lhs.verificationDetails == rhs.verificationDetails
    }
}

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
