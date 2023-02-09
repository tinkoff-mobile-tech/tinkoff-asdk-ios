//
//  UISDKConfiguration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 24.12.2022.
//

import Foundation

/// Конфигурация `TinkoffASDKUI`
public struct UISDKConfiguration {
    /// Запрашивает данные и способ аутентификация для `WKWebView`
    let webViewAuthChallengeService: IWebViewAuthChallengeService?

    /// Отвечает за максимальное количество запросов на обновление статуса платежа, можно установить любое значение
    ///
    /// Запросы обновления статуса осуществляются с минимальным интервалом в 3 секунды между друг другом
    /// По умолчанию будет осуществлено 10 запросов, по истечении которых юзер получит уведомление об истечении времени, отведенного на оплату
    let paymentStatusRetriesCount: Int

    /// Инициалищация конфигурации `TinkoffASDKUI`
    /// - Parameter webViewAuthChallengeService: Запрашивает данные и способ аутентификация для `WKWebView`
    /// - Parameter paymentStatusRetriesCount: Максимальное количество запросов на обновление статуса платежа
    public init(
        webViewAuthChallengeService: IWebViewAuthChallengeService? = nil,
        paymentStatusRetriesCount: Int = 10
    ) {
        self.webViewAuthChallengeService = webViewAuthChallengeService
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
    }
}
