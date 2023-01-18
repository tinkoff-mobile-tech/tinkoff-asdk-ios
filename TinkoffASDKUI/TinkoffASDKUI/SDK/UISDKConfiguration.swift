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

    /// Доступная конфигурация раздела с оплатой через систему быстрых платежей (СБП)
    let sbpConfiguration: SBPConfiguration

    /// Инициалищация конфигурации `TinkoffASDKUI`
    /// - Parameter webViewAuthChallengeService: Запрашивает данные и способ аутентификация для `WKWebView`
    public init(
        webViewAuthChallengeService: IWebViewAuthChallengeService? = nil,
        sbpConfiguration: SBPConfiguration = SBPConfiguration()
    ) {
        self.webViewAuthChallengeService = webViewAuthChallengeService
        self.sbpConfiguration = sbpConfiguration
    }
}

public struct SBPConfiguration {

    // MARK: Properties

    /// При выборе банка, при оплате через СБП, осуществляется переход в приложение банка.
    /// В  этот момент будет отображаться шторка с информацией о статусе оплаты юзером.
    /// Запросы обновления статуса осуществляются с минимальным интервалом в 3 секунды между друг другом
    /// По умолчанию будет осуществлено 10 запросов, по истечении которых юзер получит уведомление об истечении времени
    /// отведенной на оплату
    /// Данным параметром можно установить любое желаемое максимальное количество запросов на обновление статуса
    let paymentStatusRetriesCount: Int

    // MARK: Initialization

    public init(paymentStatusRetriesCount: Int = 10) {
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
    }
}
