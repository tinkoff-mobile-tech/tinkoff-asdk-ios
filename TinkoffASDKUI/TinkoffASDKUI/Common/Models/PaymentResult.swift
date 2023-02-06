//
//  PaymentResult.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 18.12.2022.
//

import Foundation
import TinkoffASDKCore

/// Результат платежа
public enum PaymentResult {
    /// Информация о проведенном платеже
    public struct PaymentInfo {
        /// Идентификатор платежа
        public let paymentId: String?
        /// Идентификатор заказа в системе продавца
        public let orderId: String?
        /// Сумма заказа в копейках
        public let amount: Int64?
        // Последний детальный статус о платеже
        public let paymentStatus: PaymentStatus?

        /// Инициализация параметров
        /// - Parameters:
        ///   - paymentId: Идентификатор платежа
        ///   - orderId: Идентификатор заказа в системе продавца
        ///   - amount: Сумма заказа в копейках
        init(
            paymentId: String? = nil,
            orderId: String? = nil,
            amount: Int64? = nil,
            paymentStatus: PaymentStatus? = nil
        ) {
            self.paymentId = paymentId
            self.orderId = orderId
            self.amount = amount
            self.paymentStatus = paymentStatus
        }
    }

    /// Успешное завершение оплаты
    case succeeded(PaymentInfo)
    /// Произошла ошибка на этапе оплаты
    case failed(Error)
    /// Оплата отменена пользователем
    case cancelled(PaymentInfo?)
}

extension GetPaymentStatePayload {
    func toPaymentInfo() -> PaymentResult.PaymentInfo {
        PaymentResult.PaymentInfo(paymentId: paymentId, orderId: orderId, amount: amount, paymentStatus: status)
    }
}
