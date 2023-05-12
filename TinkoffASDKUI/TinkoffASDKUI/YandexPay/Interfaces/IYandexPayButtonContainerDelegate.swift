//
//  IYandexPayButtonContainerDelegate.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 04.12.2022.
//

import UIKit

/// Делегат  UI-контейнера для кнопки `YandexPay`
public protocol IYandexPayButtonContainerDelegate: AnyObject {
    /// Уведомляет о завершении оплаты с помощью `YandexPay`
    /// - Parameters:
    ///   - container: UI-контейнер для кнопки `YandexPay`
    ///   - result: Результат оплаты
    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didCompletePaymentWithResult result: PaymentResult
    )

    /// Запрашивает `UIViewController`, поверх которого будет отображаться UI для оплаты с помощью `YandexPay`
    /// - Parameter container: UI-контейнер для кнопки `YandexPay`
    /// - Returns: `UIViewController`, поверх которого будет отображаться UI для оплаты с помощью `YandexPay`
    /// При `nil` нажатие на кнопку будет проигнорировано
    func yandexPayButtonContainerDidRequestViewControllerForPresentation(
        _ container: IYandexPayButtonContainer
    ) -> UIViewController?

    /// Запрашивает тип проведения платежа и параметры оплаты после того, как пользователь выбрал привязанную к `YandexPay` карту
    /// - Parameters:
    ///   - container: UI-контейнер для кнопки `YandexPay`
    ///   - completion: Замыкание, которые необходимо вызвать, передав в него сформированные параметры.
    /// При `nil` проведение оплаты будет проигнорировано. Замыкание может быть безопасно вызвано с любого потока.
    func yandexPayButtonContainer(
        _ container: IYandexPayButtonContainer,
        didRequestPaymentFlow completion: @escaping (_ paymentFlow: PaymentFlow?) -> Void
    )
}
