//
//  YandexPayPaymentFlowDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation
import UIKit

/// Делегат объекта `IYandexPayPaymentFlow`
public protocol YandexPayPaymentFlowDelegate: AnyObject {
    /// Вызывается для отображения шторки `YandexPay` поверх возвращаемого `UIViewController`
    func yandexPayPaymentFlowDidRequestViewControllerForPresentation(_ flow: IYandexPayPaymentFlow) -> UIViewController?
    /// Вызывается после завершения оплаты
    func yandexPayPaymentFlow(_ flow: IYandexPayPaymentFlow, didCompleteWith result: PaymentResult)
}
