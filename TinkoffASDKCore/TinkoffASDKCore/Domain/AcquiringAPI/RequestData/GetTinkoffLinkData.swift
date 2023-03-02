//
//  GetTinkoffLinkData.swift
//  TinkoffASDKCore
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation

/// Данные для запроса на получение ссылки на оплату с помощью TinkoffPay
public struct GetTinkoffLinkData {
    /// Идентитфикатор платежа
    public let paymentId: String
    /// Версия `TinkoffPay`
    public let version: String

    /// Данные для запроса на получение ссылки на оплату с помощью TinkoffPay
    /// - Parameters:
    ///   - paymentId: Идентитфикатор платежа
    ///   - version:  Версия `TinkoffPay`
    public init(paymentId: String, version: String) {
        self.paymentId = paymentId
        self.version = version
    }
}
