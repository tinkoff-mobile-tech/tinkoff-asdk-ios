//
//  YPPaymentSheetFactory.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI
import YandexPaySDK

protocol IYPPaymentSheetFactory {
    func create(with paymentSheet: YandexPayPaymentSheet) -> YPPaymentSheet
}

final class YPPaymentSheetFactory: IYPPaymentSheetFactory {
    private let method: YandexPayMethod

    init(method: YandexPayMethod) {
        self.method = method
    }

    func create(with paymentSheet: YandexPayPaymentSheet) -> YPPaymentSheet {
        let cardMethod = YPCardPaymentMethod(
            gateway: .gateway,
            gatewayMerchantId: method.merchantId,
            allowedAuthMethods: [.panOnly],
            allowedCardNetworks: [.visa, .mastercard, .mir]
        )

        let order = YPOrder(
            id: method.merchantId + paymentSheet.order.orderId,
            amount: .rublesString(fromPennies: paymentSheet.order.amount)
        )

        let yandexPaySDKPaymentSheet = YPPaymentSheet(
            countryCode: .ru,
            currencyCode: .rub,
            order: order,
            paymentMethods: [.card(cardMethod)]
        )

        return yandexPaySDKPaymentSheet
    }
}

// MARK: - Helpers

private extension String {
    static let gateway = "tinkoff"

    static func rublesString(fromPennies pennies: Int64) -> String {
        "\(Double(pennies) / 100)"
    }
}
