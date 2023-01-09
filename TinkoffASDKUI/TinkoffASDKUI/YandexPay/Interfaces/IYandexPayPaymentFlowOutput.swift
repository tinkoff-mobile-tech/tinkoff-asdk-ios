//
//  IYandexPayPaymentFlowOutput.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

/// Объект, получающий уведомление о завершении оплаты
public protocol IYandexPayPaymentFlowOutput: AnyObject {
    /// Вызывается после завершения оплаты
    func yandexPayPaymentFlow(_ flow: IYandexPayPaymentFlow, didCompleteWith result: YandexPayPaymentResult)
}
