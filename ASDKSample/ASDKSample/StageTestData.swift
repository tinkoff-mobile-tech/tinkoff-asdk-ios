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

/// Тестовые данные для проведения тестовых платежей
public enum StageTestData {
    /// Открытый ключ для шифрования карточных данных (номер карты, срок дейсвия и секретный код)
    // swiftlint:disable:next line_length
    public static let testPublicKey = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAqBiorLS9OrFPezixO5lSsF+HiZPFQWDO7x8gBJp4m86Wwz7ePNE8ZV4sUAZBqphdqSpXkybM4CJwxdj5R5q9+RHsb1dbMjThTXniwPpJdw4WKqG5/cLDrPGJY9NnPifBhA/MthASzoB+60+jCwkFmf8xEE9rZdoJUc2p9FL4wxKQPOuxCqL2iWOxAO8pxJBAxFojioVu422RWaQvoOMuZzhqUEpxA9T62lN8t3jj9QfHXaL4Ht8kRaa2JlaURtPJB5iBM+4pBDnqObNS5NFcXOxloZX4+M8zXaFh70jqWfiCzjyhaFg3rTPE2ClseOdS7DLwfB2kNP3K0GuPuLzsMwIDAQAB"

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
}
