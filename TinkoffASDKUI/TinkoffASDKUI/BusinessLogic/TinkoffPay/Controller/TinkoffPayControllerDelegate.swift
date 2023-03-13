//
//  TinkoffPayControllerDelegate.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 02.03.2023.
//

import Foundation
import TinkoffASDKCore

/// Объект, получающий уведомления в процессе работы `ITinkoffPayController`
///
/// Все методы делегата вызываются на главном потоке
protocol TinkoffPayControllerDelegate: AnyObject {
    /// Уведомляет о получении промежуточного статуса платежа
    ///
    ///  Данный метод может вызываться множество раз до тех пор,
    ///  пока не будет получен конечный статус оплаты или не будет исчерпан лимит попыток для запроса статуса оплаты
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - paymentState: Информация о платеже
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        didReceiveIntermediate paymentState: GetPaymentStatePayload
    )

    /// Уведомляет об открытии приложения банка
    ///
    /// Метод вызывается как при `Tinkoff Pay v1`, если приложение банка установлено на устройстве,
    /// так и при `Tinkoff Pay v2` независимо от наличия установленного приложения
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - url: URL открытого приложения с `TinkoffPay`
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        didOpenTinkoffPay url: URL
    )

    /// Уведомляет о завершении работы из-за невозможности открыть приложение банка
    ///
    /// Такая ситуация возможна при использовании `Tinkoff Pay v1`, где для перехода в приложение банка используется `DeepLink`.
    ///
    /// В случае `Tinkoff Pay v2` для перехода используется `UniversalLink`, и в ситуации, когда приложение банка
    /// не установлено на устройстве, откроется landing-страница  в `Safari`, поэтому данный метод не будет вызван
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - url: URL приложения с `TinkoffPay`, который не удалось открыть
    ///   - error: Ошибка, содержащая дополнительный контекст
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedDueToInabilityToOpenTinkoffPay url: URL,
        error: Error
    )

    /// Уведомляет о завершении платежа после получения конечного успешного статуса оплаты
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - paymentState: Информация о платеже
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithSuccessful paymentState: GetPaymentStatePayload
    )

    /// Уведомляет о завершении платежа после получения конечного неуспешного статуса оплаты
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - paymentState: Информация о платеже
    ///   - error: Ошибка, содержащая дополнительный контекст
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithFailed paymentState: GetPaymentStatePayload,
        error: Error
    )

    /// Уведомляет о завершении работы из-за возникшей ошибки в процессе проведения оплаты
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - error: Ошибка, содержащая дополнительный контекст
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWith error: Error
    )
}
