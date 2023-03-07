//
//  ChargePaymentControllerDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation

protocol ChargePaymentControllerDelegate: PaymentControllerDelegate {
    /// Вызывается, если запрос `Charge` вернул 104 ошибку.
    ///
    /// В этом случае необходимо запросить у пользователя ввод cvc кода для карты с указанным rebillId и повторить платеж с указанием `PaymentSource.savedCard`,
    /// а так же прикрепить к данным для платежа `paymentData`
    func paymentController(
        _ controller: IPaymentController,
        shouldRepeatWithRebillId rebillId: String,
        failedPaymentProcess: PaymentProcess,
        error: Error
    )
}
