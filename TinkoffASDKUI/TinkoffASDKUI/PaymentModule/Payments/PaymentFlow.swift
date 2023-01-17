//
//  PaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.01.2023.
//

import Foundation

/// Тип проведения оплаты
public enum PaymentFlow: Equatable {
    /// Оплата совершится с помощью вызова `v2/Init` в API эквайринга, на основе которого будет сформирован `paymentId`
    case full(paymentOptions: PaymentOptions)
    /// Используется в ситуациях, когда вызов `v2/Init` и формирование `paymentId` происходит на бекенде продавца
    case finish(paymentId: String, customerOptions: CustomerOptions?)
}

// MARK: - PaymentFlow + Utils

extension PaymentFlow {
    var customerOptions: CustomerOptions? {
        switch self {
        case let .full(paymentOptions):
            return paymentOptions.customerOptions
        case let .finish(_, customerOptions):
            return customerOptions
        }
    }
}
