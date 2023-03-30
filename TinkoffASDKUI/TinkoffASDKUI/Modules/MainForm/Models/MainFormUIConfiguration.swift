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
    /// Описание заказа, отображаемое пользователю
    public let orderDescription: String?

    /// Создание конфигурации главной платежной формы
    /// - Parameters:
    ///   - orderDescription: Описание заказа, отображаемое пользователю
    public init(orderDescription: String?) {
        self.orderDescription = orderDescription
    }
}
