//
//  FinishPaymentOptions.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 29.03.2023.
//

public struct FinishPaymentOptions: Equatable {
    /// Номер платежа, полученного после инициализации платежа
    public let paymentId: String
    /// Сумма заказа в копейках, отображаемая пользователю
    public let amount: Int64
    /// Идентификатор заказа в системе продавца
    public let orderId: String
    /// Параметры покупателя
    public let customerOptions: CustomerOptions?

    /// Создание конфигурации главной платежной формы
    /// - Parameters:
    ///   - paymentId: Номер платежа, полученного после инициализации платежа
    ///   - amount: Сумма заказа в копейках, отображаемая пользователю
    ///   - orderId: Идентификатор заказа в системе продавца
    ///   - customerOptions: Параметры покупателя
    public init(
        paymentId: String,
        amount: Int64,
        orderId: String,
        customerOptions: CustomerOptions? = nil
    ) {
        self.paymentId = paymentId
        self.amount = amount
        self.orderId = orderId
        self.customerOptions = customerOptions
    }

    func updated(with newPaymentId: String) -> FinishPaymentOptions {
        FinishPaymentOptions(
            paymentId: newPaymentId,
            amount: amount,
            orderId: orderId
        )
    }
}
