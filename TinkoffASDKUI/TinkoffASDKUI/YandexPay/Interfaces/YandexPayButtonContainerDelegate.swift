//
//  YandexPayButtonContainerDelegate.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import UIKit

/// Делегат  UI-контейнера для кнопки `YandexPay`
public protocol YandexPayButtonContainerDelegate: AnyObject {
    /// Уведомляет о завершении оплаты с помощью `YandexPay`
    /// - Parameters:
    ///   - container: UI-контейнер для кнопки `YandexPay`
    ///   - result: Результат оплаты
    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didCompletePaymentWithResult result: YandexPayPaymentResult
    )

    /// Запрашивает `UIViewController`, поверх которого будет отображаться UI для оплаты с помощью `YandexPay`
    /// - Parameter container: UI-контейнер для кнопки `YandexPay`
    /// - Returns: `UIViewController`, поверх которого будет отображаться UI для оплаты с помощью `YandexPay`
    /// При `nil` нажатие на кнопку будет проигнорировано
    func yandexPayButtonContainerDidRequestViewControllerForPresentation(
        _ container: IYandexPayButtonContainer
    ) -> UIViewController?

    /// Запрашивает параметры для оплаты с помощью `YandexPay`
    /// - Parameters:
    ///   - container: UI-контейнер для кнопки `YandexPay`
    ///   - completion: Замыкание, которое необходимо вызвать, передав в него сформированные параметры для оплаты.
    ///   При `nil` нажатие на кнопку будет проигнорировано
    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didRequestPaymentSheet completion: @escaping (_ paymentSheet: YandexPayPaymentSheet?) -> Void
    )
}
