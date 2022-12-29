//
//  IYandexPayPaymentFlow.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

/// Объект, получающий результат работы `YandexPay` и отображающий UI при проведении платежа
public protocol IYandexPayPaymentFlow: AnyObject {
    /// Объект, получающий уведомление о завершении оплаты. Удерживается слабой ссылкой
    var output: IYandexPayPaymentFlowOutput? { get set }
    /// Объект, через которой запрашивается `UIViewController` для отображения UI при проведении платежа
    var presentingViewControllerProvider: IPresentingViewControllerProvider? { get set }
    /// Начинает проведение оплаты с отображением соответствующего UI
    func start(with paymentOption: PaymentOptions, base64Token: String)
}
