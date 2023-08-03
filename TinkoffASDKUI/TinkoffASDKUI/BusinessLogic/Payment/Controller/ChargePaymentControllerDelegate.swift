//
//  ChargePaymentControllerDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.02.2023.
//

import Foundation
import TinkoffASDKCore

public protocol ChargePaymentControllerDelegate: PaymentControllerDelegate {
    /// Вызывается, если запрос `Charge` вернул 104 ошибку.
    ///
    /// В этом случае необходимо запросить у пользователя ввод cvc кода для карты с указанным rebillId и повторить платеж с указанием `PaymentSource.savedCard`
    /// - Parameters:
    ///   - controller: экземпляр контроллера
    ///   - rebillId: поможет определить нужную карту из списка
    ///   - failedPaymentProcess: полные данные не успешного платежа
    ///   - additionalData: содержаться два доп. поля failMapiSessionId c failedPaymentId и recurringType
    ///   - error: ошибка с бэка
    func paymentController(
        _ controller: IPaymentController,
        shouldRepeatWithRebillId rebillId: String,
        failedPaymentProcess: IPaymentProcess,
        additionalInitData: AdditionalData?,
        error: Error
    )
}
