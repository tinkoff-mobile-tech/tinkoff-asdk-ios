//
//  PayButtonViewPresentationState.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 08.02.2023.
//

import Foundation

enum PayButtonViewPresentationState: Equatable {
    /// Кнопка со стилем `Tinkoff Primary` и заголовком `Оплатить`
    case pay
    /// Кнопка со стилем `Tinkoff Primary` и заголовком `Оплатить по карте`
    case payByCard
    /// Кнопка со стилем `Tinkoff Primary` и заголовком `Оплатить <amount> ₽`
    case payWithAmount(amount: Int)
    /// Кнопка со стилем `Tinkoff Primary` с логотипом `Tinkoff Pay`
    case tinkoffPay
    /// Темно-фиолетовая кнопка с логотипом `СБП`
    case sbp
}
