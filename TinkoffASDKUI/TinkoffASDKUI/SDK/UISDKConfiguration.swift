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
    /// Запрашивает данные и способ аутентификация для `WKWebView`
    let webViewAuthChallengeService: IWebViewAuthChallengeService?

    /// Доступная конфигурация раздела с оплатой через систему быстрых платежей (СБП)
    let sbpConfiguration: SBPConfiguration

    /// Отвечает за максимальное количество запросов на обновление статуса платежа, можно установить любое значение
    ///
    /// Запросы обновления статуса осуществляются с минимальным интервалом в 3 секунды между друг другом
    /// По умолчанию будет осуществлено 10 запросов, по истечении которых юзер получит уведомление об истечении времени, отведенного на оплату
    let paymentStatusRetriesCount: Int

    /// Тип проверки при привязке карты
    ///
    /// По умолчанию `no`
    let addCardCheckType: PaymentCardCheckType

    /// Инициалищация конфигурации `TinkoffASDKUI`
    /// - Parameter webViewAuthChallengeService: Запрашивает данные и способ аутентификация для `WKWebView`
    /// - Parameter sbpConfiguration: конфигурация раздела системы быстрых платежей (СБП)
    /// - Parameter paymentStatusRetriesCount: Максимальное количество запросов на обновление статуса платежа
    public init(
        webViewAuthChallengeService: IWebViewAuthChallengeService? = nil,
        sbpConfiguration: SBPConfiguration = SBPConfiguration(),
        paymentStatusRetriesCount: Int = 10,
        addCardCheckType: PaymentCardCheckType = .no
    ) {
        self.webViewAuthChallengeService = webViewAuthChallengeService
        self.sbpConfiguration = sbpConfiguration
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
        self.addCardCheckType = addCardCheckType
    }
}

public struct SBPConfiguration {

    // MARK: Properties

    /// Отвечает за максимальное количество запросов на обновление статуса, можно установить любое значение
    ///
    /// При выборе банка, при оплате через СБП, осуществляется переход в приложение банка.
    /// В  этот момент будет отображаться шторка с информацией о статусе оплаты юзером.
    /// Запросы обновления статуса осуществляются с минимальным интервалом в 3 секунды между друг другом
    /// По умолчанию будет осуществлено 10 запросов, по истечении которых юзер получит уведомление об истечении времени,
    /// отведенного на оплату
    let paymentStatusRetriesCount: Int

    // MARK: Initialization

    public init(paymentStatusRetriesCount: Int = 10) {
        self.paymentStatusRetriesCount = paymentStatusRetriesCount
    }
}
