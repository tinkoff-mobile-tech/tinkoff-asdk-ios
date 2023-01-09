//
//  YandexPayPaymentSheet.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 11.12.2022.
//

import Foundation
import TinkoffASDKCore

/// Параметры для оплаты с помощью `YandexPay`
public struct YandexPayPaymentSheet {
    /// Параметры платежа
    public let paymentOptions: PaymentOptions

    /// Инициализация параметров
    /// - Parameter paymentOptions: Параметры платежа
    public init(paymentOptions: PaymentOptions) {
        self.paymentOptions = paymentOptions
    }
}
