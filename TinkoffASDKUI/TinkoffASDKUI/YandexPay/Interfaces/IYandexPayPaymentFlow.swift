//
//  IYandexPayPaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

/// Объект, получающий результат работы `YandexPay` и отображающий UI при проведении платежа
public protocol IYandexPayPaymentFlow: AnyObject {
    /// Начинает проведение оплаты с отображением соответствующего UI
    func start(with paymentFlow: PaymentFlow, base64Token: String)
}
