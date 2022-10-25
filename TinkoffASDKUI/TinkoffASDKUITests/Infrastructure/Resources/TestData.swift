//
//  TestData.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 17.10.2022.
//

import Foundation

/// Тестовые данные для проведения тестовых платежей
enum UnitTestStageTestData {
    /// Открытый ключ для шифрования карточных данных (номер карты, срок дейсвия и секретный код)
    // swiftlint:disable:next line_length
    static let testPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5Yg3RyEkszggDVMDHCAGzJm0mYpYT53BpasrsKdby8iaWJVACj8ueR0Wj3Tu2BY64HdIoZFvG0v7UqSFztE/zUvnznbXVYguaUcnRdwao9gLUQO2I/097SHF9r++BYI0t6EtbbcWbfi755A1EWfu9tdZYXTrwkqgU9ok2UIZCPZ4evVDEzDCKH6ArphVc4+iKFrzdwbFBmPmwi5Xd6CB9Na2kRoPYBHePGzGgYmtKgKMNs+6rdv5v9VB3k7CS/lSIH4p74/OPRjyryo6Q7NbL+evz0+s60Qz5gbBRGfqCA57lUiB3hfXQZq5/q1YkABOHf9cR6Ov5nTRSOnjORgPjwIDAQAB"

    /// Уникальный идентификатор терминала, выдается Продавцу Банком на каждый магазин.
    static let terminalKey = "TestSDK"

    /// Пароль от терминала
    static let terminalPassword = "12345678"

    /// Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт.
    static let customerKey = "TestSDK_CustomerKey1"
}
