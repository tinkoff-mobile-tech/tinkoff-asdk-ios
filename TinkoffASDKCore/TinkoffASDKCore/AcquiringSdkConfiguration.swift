//
//  AcquiringSdkConfiguration.swift
//  TinkoffASDKCore
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

import Foundation
import UIKit

public enum AcquiringSdkLanguage: String {
    case ru

    case en
}

public enum AcquiringSdkEnvironment: String {
    case test = "rest-api-test.tcsbank.ru"

    case prod = "securepay.tinkoff.ru"
}

public struct AcquiringSdkCredential {
    public var terminalKey: String
    public var publicKey: String

    /// - Parameters:
    ///   - terminalKey: ключ терминала. Выдается после подключения к **Тинькофф Эквайринг API**
    ///   - publicKey: публичный ключ. Выдается вместе с `terminalKey`
    /// - Returns: AcquiringSdkCredential
    public init(terminalKey: String, publicKey: String) {
        self.terminalKey = terminalKey
        self.publicKey = publicKey
    }
}

/// Кофигурация для экземпляра SDK
public class AcquiringSdkConfiguration: NSObject {
    public var fpsEnabled: Bool = false

    public private(set) var credential: AcquiringSdkCredential

    public private(set) var serverEnvironment: AcquiringSdkEnvironment

    public private(set) var requestsTimeoutInterval: TimeInterval

    /// Язык платёжной формы. На каком языке сервер будет присылать тексты ошибок клиенту
    ///
    ///   - `ru` - форма оплаты на русском языке;
    ///   - `en` - форма оплаты на английском языке.
    ///
    /// По умолчанию (если параметр не передан) - форма оплаты считается на русском языке
    public private(set) var language: AcquiringSdkLanguage?

    /// Логирование работы, реализаия `ASDKApiLoggerDelegate`
    public var logger: LoggerDelegate?

    /// Показывать ошибки после выполнения запроса
    public var showErrorAlert: Bool = true

    ///
    /// - Parameters:
    ///   - credential: учетные данные `AcquiringSdkConfiguration` Выдается после подключения к **Тинькофф Эквайринг API**
    ///   - server: `AcquiringSdkEnvironment` по умолчанию используется `test` - тестовый сервер
    ///   - requestsTimeoutInterval: `TimeInterval` таймаут сетевых запросов, по-умолчанию значени 40 секунд(40000 милисекунд)
    /// - Returns: AcquiringSdkConfiguration
    public init(credential: AcquiringSdkCredential,
                server: AcquiringSdkEnvironment = .test,
                requestsTimeoutInterval: TimeInterval) {
        self.credential = credential
        self.requestsTimeoutInterval = requestsTimeoutInterval
        self.serverEnvironment = server
    }

    public convenience init(credential: AcquiringSdkCredential,
                            server: AcquiringSdkEnvironment = .test) {
        self.init(credential: credential,
                  server: server,
                  requestsTimeoutInterval: .defaultRequestsTimeoutInterval)
    }
}

private extension TimeInterval {
    static let defaultRequestsTimeoutInterval: TimeInterval = 40
}
