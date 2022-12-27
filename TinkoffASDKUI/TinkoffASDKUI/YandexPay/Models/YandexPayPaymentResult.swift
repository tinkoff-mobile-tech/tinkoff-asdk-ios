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
        /// Параметры, на основе которых была проведена оплата
        public let paymentOptions: PaymentOptions
        /// Идентификатор платежа
        public let paymentId: String
        /// Идентификатор родительского платежа, на основе которого можно совершить повторный платеж.
        /// Будет располагаться в `PaymentInfo`, если в `PaymentOptions` был передан `savingAsParentPayment: true`
        public let rebillId: String?

        /// Инициализация параметров
        /// - Parameters:
        ///   - paymentOptions: Параметры, на основе которых была проведена оплата
        ///   - paymentId: Идентификатор платежа
        ///   - rebillId: Идентификатор родительского платежа, на основе которого можно совершить повторный платеж
        public init(
            paymentOptions: PaymentOptions,
            paymentId: String,
            rebillId: String?
        ) {
            self.paymentOptions = paymentOptions
            self.paymentId = paymentId
            self.rebillId = rebillId
        }
    }

    /// Успешное завершение оплаты
    case succeeded(PaymentInfo)
    /// Произошла ошибка на этапе оплаты
    case failed(Error)
    /// Оплата отменена пользователем
    case cancelled
}
