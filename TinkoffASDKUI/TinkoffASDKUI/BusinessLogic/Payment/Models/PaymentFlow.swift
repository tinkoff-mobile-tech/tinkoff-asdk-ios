//
//  PaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 16.01.2023.
//

import Foundation
import TinkoffASDKCore

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

    var additionalInitData: AdditionalData? {
        switch self {
        case let .full(paymentOptions):
            return paymentOptions.paymentInitData
        case .finish:
            return nil
        }
    }

    var additionalFinishData: AdditionalData? {
        switch self {
        case let .full(paymentOptions):
            return paymentOptions.paymentFinishData
        case let .finish(finishOptions):
            return finishOptions.paymentFinishData
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
                paymentInitData: paymentOptions.paymentInitData,
                paymentFinishData: paymentOptions.paymentFinishData
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

    func mergePaymentDataIfNeeded(
        initData: [String: Encodable]?,
        finishData: [String: Encodable]? = nil
    ) -> PaymentFlow {
        guard initData != nil || finishData != nil else { return self }

        switch self {
        case let .full(paymentOptions):
            var newInitData = paymentOptions.paymentInitData ?? .empty()
            newInitData.merging(initData)

            var newFinishData = paymentOptions.paymentFinishData ?? .empty()
            newFinishData.merging(finishData)

            let newPaymentOptions = PaymentOptions(
                orderOptions: paymentOptions.orderOptions,
                customerOptions: paymentOptions.customerOptions,
                paymentCallbackURL: paymentOptions.paymentCallbackURL,
                paymentInitData: newInitData,
                paymentFinishData: newFinishData
            )
            return .full(paymentOptions: newPaymentOptions)

        case let .finish(finishPaymentOptions):
            guard let finishData else { return self }
            var newFinishData = finishPaymentOptions.paymentFinishData
            newFinishData?.merging(finishData)

            let newFinishPaymentOptions = FinishPaymentOptions(
                paymentId: finishPaymentOptions.paymentId,
                amount: finishPaymentOptions.amount,
                orderId: finishPaymentOptions.orderId,
                customerOptions: finishPaymentOptions.customerOptions,
                paymentFinishData: newFinishData
            )
            return .finish(paymentOptions: newFinishPaymentOptions)
        }
    }
}
