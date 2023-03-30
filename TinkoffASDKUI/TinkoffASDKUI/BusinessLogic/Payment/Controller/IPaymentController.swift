//
//  IPaymentController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Объект, способный совершать оплату с прохождением проверки `3DS`
public protocol IPaymentController: AnyObject {
    /// Делегат событий `IPaymentController`
    var delegate: PaymentControllerDelegate? { get set }
    /// Объект, предоставляющий UI-компоненты для прохождения 3DS Web Based Flow
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    /// Совершает платеж с заданными параметрами
    ///
    /// По завершении платежа ответ вернется с помощью `PaymentControllerDelegate`
    /// - Parameters:
    ///   - paymentFlow: Тип проведения оплаты
    ///   - paymentSource: Источник оплаты
    func performPayment(paymentFlow: PaymentFlow, paymentSource: PaymentSourceData)
}

// MARK: - IPaymentController + Helpers

public extension IPaymentController {
    /// Совершает платеж с инициацией платежа
    ///
    /// По завершении платежа ответ вернется с помощью `PaymentControllerDelegate`
    /// - Parameters:
    ///   - paymentOptions: Тип проведения оплаты
    ///   - paymentSource: Источник оплаты
    func performInitPayment(paymentOptions: PaymentOptions, paymentSource: PaymentSourceData) {
        performPayment(paymentFlow: .full(paymentOptions: paymentOptions), paymentSource: paymentSource)
    }

    /// Совершает платеж с ранее инициированным платежом
    ///
    /// По завершении платежа ответ вернется с помощью `PaymentControllerDelegate`
    /// - Parameters:
    ///   - paymentOptions: Данные проводимой оплаты
    ///   - paymentSource: Источник оплаты
    func performFinishPayment(paymentOptions: FinishPaymentOptions, paymentSource: PaymentSourceData) {
        performPayment(
            paymentFlow: .finish(paymentOptions: paymentOptions),
            paymentSource: paymentSource
        )
    }
}
