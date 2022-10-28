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
    case test = "rest-api-test.tinkoff.ru"
    case prod = "securepay.tinkoff.ru"
}

struct ConfigSdkEnvironment: RawRepresentable {
    static var test: ConfigSdkEnvironment {
        ConfigSdkEnvironment(rawValue: "asdk-config-test.cdn-tinkoff.ru")
    }

    static var prod: ConfigSdkEnvironment {
        ConfigSdkEnvironment(rawValue: "asdk-config-prod.cdn-tinkoff.ru")
    }

    let rawValue: String

    init(rawValue: String) {
        self.rawValue = rawValue
    }
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

/// Конфигурация для экземпляра SDK
public class AcquiringSdkConfiguration: NSObject {
    public let credential: AcquiringSdkCredential
    public let serverEnvironment: AcquiringSdkEnvironment
    public let requestsTimeoutInterval: TimeInterval
    @available(*, deprecated, message: "Property does not affect anything")
    public var fpsEnabled = false
    /// Показывать ошибки после выполнения запроса
    @available(*, deprecated, message: "Property does not affect anything")
    public var showErrorAlert = true
    let configEnvironment: ConfigSdkEnvironment

    /// Язык платёжной формы. На каком языке сервер будет присылать тексты ошибок клиенту
    ///
    ///   - `ru` - форма оплаты на русском языке;
    ///   - `en` - форма оплаты на английском языке.
    ///
    /// По умолчанию (если параметр не передан) - форма оплаты считается на русском языке
    public private(set) var language: AcquiringSdkLanguage?

    /// Логгер сетевых запросов. Реализация - `ASDKApiLoggerDelegate`
    public var logger: LoggerDelegate?

    /// Время в секундах, в течение которого хранится в памяти состояние доступности TinkoffPay
    public var tinkoffPayStatusCacheLifeTime: TimeInterval

    /// Объект, предоставляющий токен для подписи запроса в **Тинькофф Эквайринг API** на основе параметров,  отправляемых с body
    let tokenProvider: ITokenProvider?

    /// Инициализация конфигурации для `AcquiringSdk`
    ///
    /// - Parameters:
    ///   - credential: учетные данные `AcquiringSdkConfiguration` Выдается после подключения к **Тинькофф Эквайринг API**
    ///   - server: `AcquiringSdkEnvironment` по умолчанию используется `test` - тестовый сервер
    ///   - requestsTimeoutInterval: `TimeInterval` таймаут сетевых запросов, значение по-умолчанию - 40 секунд
    ///   - tinkoffPayStatusCacheLifeTime: `TimeInterval` Время в секундах, в течение которого хранится в памяти состояние доступности TinkoffPay
    ///   - tokenProvider: Объект, предоставляющий токен для подписи запроса в **Тинькофф Эквайринг API** на основе параметров,  отправляемых с body
    /// - Returns: AcquiringSdkConfiguration
    public init(
        credential: AcquiringSdkCredential,
        server: AcquiringSdkEnvironment = .test,
        requestsTimeoutInterval: TimeInterval = 40,
        tinkoffPayStatusCacheLifeTime: TimeInterval = 300,
        tokenProvider: ITokenProvider? = nil
    ) {
        self.credential = credential
        self.requestsTimeoutInterval = requestsTimeoutInterval
        self.tinkoffPayStatusCacheLifeTime = tinkoffPayStatusCacheLifeTime
        serverEnvironment = server
        configEnvironment = server == .test ? .test : .prod
        self.tokenProvider = tokenProvider
    }
}
