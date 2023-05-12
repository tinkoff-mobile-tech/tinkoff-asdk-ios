//
//  UISDKConfiguration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.12.2022.
//

import Foundation
import TinkoffASDKCore

/// Конфигурация `TinkoffASDKUI`
public struct UISDKConfiguration {
    /// Запрашивает данные и способ аутентификации для `WKWebView`
    let webViewAuthChallengeService: IWebViewAuthChallengeService?

    /// Отвечает за максимальное количество запросов на обновление статуса платежа. Можно установить любое положительное значение.
    ///
    /// Запросы обновления статуса осуществляются с минимальным интервалом в 3 секунды между друг другом
    /// По умолчанию будет осуществлено 10 запросов, по истечении которых юзер получит уведомление об истечении времени, отведенного на оплату
    let paymentStatusRetriesCount: Int

    /// Тип проверки при привязке карты
    ///
    /// По умолчанию `no`
    let addCardCheckType: PaymentCardCheckType

    /// Инициализация конфигурации `TinkoffASDKUI`
    /// - Parameter webViewAuthChallengeService: Запрашивает данные и способ аутентификация для `WKWebView`
    /// - Parameter paymentStatusRetriesCount: Максимальное количество запросов на обновление статуса платежа
    /// - Parameter addCardCheckType: Тип проверки при привязке карты
    public init(
        webViewAuthChallengeService: IWebViewAuthChallengeService? = nil,
        paymentStatusRetriesCount: Int = 10,
        addCardCheckType: PaymentCardCheckType = .no
    ) {
        self.webViewAuthChallengeService = webViewAuthChallengeService
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
        self.addCardCheckType = addCardCheckType
    }
}
