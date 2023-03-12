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
    /// Уведомляет об открытии приложения банка
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - url: URL открытого приложения банка
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        didOpenBankAppWith url: URL
    )

    /// Уведомляет о завершении работы из-за невозможности открыть приложение банка
    /// - Parameters:
    ///   - tinkoffPayController: Объект, способный совершать оплату с помощью `TinkoffPay`
    ///   - error: Ошибка, содержащая дополнительный контекст
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedDueToInabilityToOpenBankApp error: Error
    )

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
