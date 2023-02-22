//
//  PaymentSourceData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 07.10.2022.
//

import Foundation

/// Источник оплаты
public enum PaymentSourceData: Equatable {
    /// При оплате по реквизитам  карты
    ///
    /// - Parameters:
    ///   - number: номер карты в виде строки
    ///   - expDate: expiration date в виде строки `MMYY`
    ///   - cvv: код `CVV` в виде строки.
    case cardNumber(number: String, expDate: String, cvv: String)

    /// При оплате с ранее сохраненной карты
    ///
    /// - Parameters:
    ///   - cardId: идентификатор сохраненной карты
    ///   - cvv: код `CVV` в виде строки.
    case savedCard(cardId: String, cvv: String?)

    /// При оплате на основе родительского платежа
    ///
    /// - Parameters:
    ///   - rebuidId: идентификатор родительского платежа
    case parentPayment(rebuidId: String)

    /// При оплате с помощью **YandexPay**
    ///
    /// - Parameters:
    ///   - base64Token: Токен, полученный из `YPPaymentInfo.paymentToken`
    case yandexPay(base64Token: String)
}

// MARK: - Helpers

public extension PaymentSourceData {
    func getCardAndRebillId() -> (cardId: String?, rebillId: String?) {
        switch self {
        case let .parentPayment(rebillId):
            return (nil, rebillId)
        case let .savedCard(cardId, _):
            return (cardId, nil)
        default:
            return (nil, nil)
        }
    }
}
