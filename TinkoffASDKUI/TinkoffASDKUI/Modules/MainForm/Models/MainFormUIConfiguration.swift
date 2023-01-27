//
//  MainFormUIConfiguration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 26.01.2023.
//

import Foundation

/// Конфигурация главной платежной формы
///
/// На основе этих данный будет формироваться отображение UI платежной формы с разными способами оплаты
public struct MainFormUIConfiguration {
    /// Сумма заказа в копейках, отображаемая пользователю
    public let amount: Int64
    /// Описание заказа, отображаемое пользователю
    public let orderDescription: String?

    /// Создание конфигурации главной платежной формы
    /// - Parameters:
    ///   - amount: Сумма заказа в копейках, отображаемая пользователю
    ///   - orderDescription: Описание заказа, отображаемое пользователю
    public init(
        amount: Int64,
        orderDescription: String?
    ) {
        self.amount = amount
        self.orderDescription = orderDescription
    }
}
