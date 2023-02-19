//
//  ChargePaymentControllerDataSource.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation

/// Объект, предоставляющий дополнительный данные для `PaymentController` в случае, если запрос `Charge` вернул ошибку `104`
public protocol ChargePaymentControllerDataSource: PaymentControllerDataSource {
    /// `AcquiringViewConfiguration` для отображения экрана оплаты с возможность ввести `CVC`
    func paymentController(
        _ controller: IPaymentController,
        viewConfigurationToRetry paymentProcess: PaymentProcess
    ) -> AcquiringViewConfiguration

    /// Вызовется, если при инициации оплаты с `PaymentSourceData.parentPayment` не был предоставлен `CustomerKey` в `CustomerOptions`
    func paymentController(
        _ controller: IPaymentController,
        customerKeyToRetry chargePaymentProcess: PaymentProcess
    ) -> String?

    /// Вызовется, если оплата была была инициирована через метод `performFinishPayment`
    func paymentController(
        _ controller: IPaymentController,
        paymentOptionsToRetry chargePaymentProcess: PaymentProcess
    ) -> PaymentOptions?
}

public extension ChargePaymentControllerDataSource {
    func paymentController(
        _ controller: IPaymentController,
        customerKeyToRetry chargePaymentProcess: PaymentProcess
    ) -> String? { return nil }

    func paymentController(
        _ controller: IPaymentController,
        paymentOptionsToRetry chargePaymentProcess: PaymentProcess
    ) -> PaymentOptions? { return nil }
}
