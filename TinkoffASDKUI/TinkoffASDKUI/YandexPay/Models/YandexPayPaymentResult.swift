//
//  YandexPayPaymentResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation

/// Результат платежа с помощью `YandexPay`
public enum YandexPayPaymentResult {
    /// Информация о проведенном платеже
    public struct PaymentInfo {
        /// Идентификатор платежа
        public let paymentId: String
        /// Идентификатор заказа в системе продавца
        public let orderId: String
        /// Сумма заказа в копейках
        public let amount: Int64

        /// Инициализация параметров
        /// - Parameters:
        ///   - paymentId: Идентификатор платежа
        ///   - orderId: Идентификатор заказа в системе продавца
        ///   - amount: Сумма заказа в копейках
        init(
            paymentId: String,
            orderId: String,
            amount: Int64
        ) {
            self.paymentId = paymentId
            self.orderId = orderId
            self.amount = amount
        }
    }

    /// Успешное завершение оплаты
    case succeeded(PaymentInfo)
    /// Произошла ошибка на этапе оплаты
    case failed(Error)
    /// Оплата отменена пользователем
    case cancelled
}
