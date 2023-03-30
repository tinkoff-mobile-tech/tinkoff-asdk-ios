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
    case finish(paymentOptions: FinishPaymentOptions)
}

// MARK: - PaymentFlow + Utils

extension PaymentFlow {
    var customerOptions: CustomerOptions? {
        switch self {
        case let .full(paymentOptions):
            return paymentOptions.customerOptions
        case let .finish(paymentOptions):
            return paymentOptions.customerOptions
        }
    }

    var customerKey: String? {
        customerOptions?.customerKey
    }

    var amount: Int64 {
        switch self {
        case let .full(paymentOptions):
            return paymentOptions.orderOptions.amount
        case let .finish(paymentOptions):
            return paymentOptions.amount
        }
    }

    func replacing(customerEmail: String?) -> PaymentFlow {
        let newCustomerOptions = customerOptions.map {
            CustomerOptions(customerKey: $0.customerKey, email: customerEmail)
        }

        switch self {
        case let .full(paymentOptions):
            let newPaymentOptions = PaymentOptions(
                orderOptions: paymentOptions.orderOptions,
                customerOptions: newCustomerOptions,
                paymentData: paymentOptions.paymentData
            )
            return .full(paymentOptions: newPaymentOptions)
        case let .finish(paymentOptions):
            let newPaymentOptions = FinishPaymentOptions(
                paymentId: paymentOptions.paymentId,
                amount: paymentOptions.amount,
                orderId: paymentOptions.orderId,
                customerOptions: newCustomerOptions
            )
            return .finish(paymentOptions: newPaymentOptions)
        }
    }

    func mergePaymentDataIfNeeded(_ paymentData: [String: String]?) -> PaymentFlow {
        guard let paymentData = paymentData else { return self }

        switch self {
        case let .full(paymentOptions):
            let newPaymentOptions = PaymentOptions(
                orderOptions: paymentOptions.orderOptions,
                customerOptions: paymentOptions.customerOptions,
                paymentData: (paymentOptions.paymentData ?? [:]).merging(paymentData) { $1 }
            )
            return .full(paymentOptions: newPaymentOptions)
        case .finish:
            return self
        }
    }
}
