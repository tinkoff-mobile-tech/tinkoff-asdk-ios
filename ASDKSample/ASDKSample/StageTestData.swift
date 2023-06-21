//
//  StageTestData.swift
//  TinkoffASDKCoreTests
//
//  Copyright (c) 2020 Tinkoff Bank
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import TinkoffASDKCore
import TinkoffASDKUI
import UIKit

/// Тестовые данные для проведения тестовых платежей
public enum StageTestData {
    /// Открытый ключ для шифрования карточных данных (номер карты, срок дейсвия и секретный код)
    // swiftlint:disable:next line_length
    public static let testPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5Yg3RyEkszggDVMDHCAGzJm0mYpYT53BpasrsKdby8iaWJVACj8ueR0Wj3Tu2BY64HdIoZFvG0v7UqSFztE/zUvnznbXVYguaUcnRdwao9gLUQO2I/097SHF9r++BYI0t6EtbbcWbfi755A1EWfu9tdZYXTrwkqgU9ok2UIZCPZ4evVDEzDCKH6ArphVc4+iKFrzdwbFBmPmwi5Xd6CB9Na2kRoPYBHePGzGgYmtKgKMNs+6rdv5v9VB3k7CS/lSIH4p74/OPRjyryo6Q7NbL+evz0+s60Qz5gbBRGfqCA57lUiB3hfXQZq5/q1YkABOHf9cR6Ov5nTRSOnjORgPjwIDAQAB"

    /// Уникальный идентификатор терминала, выдается Продавцу Банком на каждый магазин.
    public static let terminalKey = "TestSDK"

    /// Пароль от терминала
    public static let terminalPassword = "12345678"

    /// Идентификатор клиента в системе продавца. Например, для этого идентификатора будут сохраняться список карт.
    public static let customerKey = "TestSDK_CustomerKey1"
}

struct SdkCredentials: Equatable, Codable {
    let uuid: String
    let name: String
    let description: String

    // Actual sdk Data
    let publicKey: String
    let terminalKey: String
    let terminalPassword: String
    let customerKey: String
}

extension SdkCredentials {

    static let test = Self(
        uuid: UUID().uuidString,
        name: "Test",
        description: "Test stage",
        publicKey: StageTestData.testPublicKey,
        terminalKey: StageTestData.terminalKey,
        terminalPassword: StageTestData.terminalPassword,
        customerKey: StageTestData.customerKey
    )

    static let testSbp1 = Self(
        uuid: UUID().uuidString,
        name: "Test SBP 1",
        description: "1 Тестовый терминал с СБП",
        publicKey: StageTestData.testPublicKey,
        terminalKey: "1521204415922",
        terminalPassword: StageTestData.terminalPassword,
        customerKey: StageTestData.customerKey
    )

    static let testSbp2 = Self(
        uuid: UUID().uuidString,
        name: "Test SBP 2",
        description: "2 Тестовый терминал с СБП",
        publicKey: StageTestData.testPublicKey,
        terminalKey: "1562595669054",
        terminalPassword: StageTestData.terminalPassword,
        customerKey: StageTestData.customerKey
    )

    static let testSbp3 = Self(
        uuid: UUID().uuidString,
        name: "Test SBP 3",
        description: "3 Тестовый терминал с СБП",
        publicKey: StageTestData.testPublicKey,
        terminalKey: "1578942570730",
        terminalPassword: StageTestData.terminalPassword,
        customerKey: StageTestData.customerKey
    )
}

extension Array where Element == SdkCredentials {

    /// Список хардкоженных тестовых терминалов
    static let testTerminals: Self = [
        .test,
        .testSbp1,
        .testSbp2,
        .testSbp3,
    ]
}
