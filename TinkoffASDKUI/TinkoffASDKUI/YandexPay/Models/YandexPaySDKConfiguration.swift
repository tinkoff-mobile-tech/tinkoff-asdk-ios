//
//  YandexPaySDKConfiguration.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.12.2022.
//

import Foundation

/// Конфигурация для инициализации `YandexPaySDK`
public struct YandexPaySDKConfiguration {
    /// Окружение `YandexPaySDK`
    public enum Environment {
        /// Используется для взаимодействия с `production` терминалами Тинькофф Эквайринга
        case production
        /// Используется для взаимодействия с `test` и `preprod(Demo)` терминалами Тинькофф Эквайринга
        case sandbox
    }

    /// Локализация отображаемой формы `YandexPay`
    public enum Locale {
        /// Русская локализация
        case ru
        /// Английская локализация
        case en
        /// Системная локализация
        case system
    }

    /// Окружение `YandexPaySDK`
    public let environment: Environment
    /// Локализация отображаемой формы `YandexPay`
    public let locale: Locale

    /// Создание конфигурации
    /// - Parameters:
    ///   - environment: Окружение `YandexPaySDK`
    ///   - locale: Локализация отображаемой формы `YandexPay`
    public init(
        environment: Environment,
        locale: Locale
    ) {
        self.environment = environment
        self.locale = locale
    }
}
