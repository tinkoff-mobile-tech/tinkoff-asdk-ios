//
//  YandexPayButtonConfiguration.swift
//  TinkoffASDKYandexPay
//
//  Created by r.akhmadeev on 01.12.2022.
//

import Foundation

/// Цвет кнопки `YandexPay`
public enum YandexPayButtonContainerAppearance {
    /// Светлый цвет для темного фона
    case light
    /// Темный цвет для светлого фона
    case dark
}

/// Тема для кнопки `YandexPay`
public struct YandexPayButtonContainerTheme {
    /// Цвет кнопки `YandexPay`
    public var appearance: YandexPayButtonContainerAppearance
    /// Автоматически обновлять цвет при изменении темы
    public var dynamic: Bool

    /// Создание новой темы для кнопки `YandexPay`
    /// - Parameters:
    ///   - appearance: Цвет кнопки `YandexPay`
    ///   - dynamic: Автоматически обновлять цвет при изменении темы
    public init(appearance: YandexPayButtonContainerAppearance, dynamic: Bool = true) {
        self.appearance = appearance
        self.dynamic = dynamic
    }
}

/// Конфигурация контейнера кнопки `YandexPay`
public struct YandexPayButtonContainerConfiguration {
    /// Тема для кнопки `YandexPay`
    public var theme: YandexPayButtonContainerTheme
    /// Радиус скругления кнопки. При `nil` используется значение по умолчанию
    public var cornerRadius: CGFloat?

    /// Создание конфигурации контейнера кнопки `YandexPay`
    /// - Parameters:
    ///   - theme: Тема для кнопки `YandexPay`
    ///   - cornerRadius: Радиус скругления кнопки. При `nil` используется значение по умолчанию
    public init(theme: YandexPayButtonContainerTheme, cornerRadius: CGFloat? = nil) {
        self.theme = theme
        self.cornerRadius = cornerRadius
    }
}
