//
//  YandexPayPaymentSheet.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 11.12.2022.
//

import Foundation
import TinkoffASDKCore

/// Параметры для формирования шторки `YandexPay`
///
/// Эти параметры необходимы для отображения шторки с возможностью выбрать карту, привязанную к системе `YandexPay`, а так же для формирования платежного токена
public struct YandexPayPaymentSheet {
    /// Параметры заказа
    public struct Order {
        /// Идентификатор заказа в системе продавца
        public let orderId: String
        /// Сумма заказа в копейках
        public let amount: Int64

        /// Инициализация параметров заказа
        /// - Parameters:
        ///   - orderId: Идентификатор заказа в системе продавца
        ///   - amount: Сумма заказа в копейках
        public init(orderId: String, amount: Int64) {
            self.orderId = orderId
            self.amount = amount
        }
    }

    /// Параметры заказа
    public let order: Order

    /// Инициализация параметров для формирования шторки `YandexPay`
    /// - Parameter order: Параметры заказа
    public init(order: Order) {
        self.order = order
    }
}
