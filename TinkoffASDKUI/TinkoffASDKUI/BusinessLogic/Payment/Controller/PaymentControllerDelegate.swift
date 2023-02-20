//
//  PaymentControllerDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Делегат событий для `PaymentController`
public protocol PaymentControllerDelegate: AnyObject {
    /// Оплата прошла успешно
    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment paymentProcess: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    )

    /// Оплата была отменена
    func paymentController(
        _ controller: IPaymentController,
        paymentWasCancelled paymentProcess: PaymentProcess,
        cardId: String?,
        rebillId: String?
    )

    /// Возникла ошибка в процессе оплаты
    func paymentController(
        _ controller: IPaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    )
}
