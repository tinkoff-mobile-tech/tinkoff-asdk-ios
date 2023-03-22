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

public enum AcquiringSdkEnvironment: Equatable, Codable, CustomStringConvertible, RawRepresentable {
    case test
    case preProd
    case prod
    case custom(String)

    public var rawValue: String {
        switch self {
        case .test: return "rest-api-test.tinkoff.ru"
        case .preProd: return "qa-mapi.tcsbank.ru"
        case .prod: return "securepay.tinkoff.ru"
        case let .custom(address): return address
        }
    }

    public init(rawValue: String) {
        switch rawValue {
        case "rest-api-test.tinkoff.ru": self = .test
        case "qa-mapi.tcsbank.ru": self = .preProd
        case "securepay.tinkoff.ru": self = .prod
        default: self = .custom(rawValue)
        }
    }

    public var description: String {
        switch self {
        case .test: return "test"
        case .preProd: return "preProd"
        case .prod: return "prod"
        case .custom: return "custom"
        }
    }
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
    let configEnvironment: ConfigSdkEnvironment

    /// Язык платёжной формы. На каком языке сервер будет присылать тексты ошибок клиенту
    ///
    ///   - `ru` - форма оплаты на русском языке;
    ///   - `en` - форма оплаты на английском языке.
    ///
    /// По умолчанию (если параметр не передан) - форма оплаты считается на русском языке
    public private(set) var language: AcquiringSdkLanguage?

    /// Объект логирующий сетевые запросы. Для включения логов, передать свой объект реализовавший протокол ILogger
    /// или уже существующий дефолтный объект типа Logger.
    /// По дефолту nil, логи отключены
    let logger: ILogger?

    /// Объект, предоставляющий токен для подписи запроса в **Тинькофф Эквайринг API** на основе параметров,  отправляемых с body
    let tokenProvider: ITokenProvider?

    /// Запрашивает данные и способ аутентификация для `URLSession`
    let urlSessionAuthChallengeService: IURLSessionAuthChallengeService?

    /// Инициализация конфигурации для `AcquiringSdk`
    ///
    /// - Parameters:
    ///   - credential: учетные данные `AcquiringSdkConfiguration` Выдается после подключения к **Тинькофф Эквайринг API**
    ///   - server: `AcquiringSdkEnvironment` по умолчанию используется `test` - тестовый сервер
    ///   - requestsTimeoutInterval: `TimeInterval` таймаут сетевых запросов, значение по-умолчанию - 40 секунд
    ///   - logger: `ILogger` Объект логирующий сетевые запросы
    ///   - tokenProvider: Объект, предоставляющий токен для подписи запроса в **Тинькофф Эквайринг API** на основе параметров,  отправляемых с body
    ///   - urlSessionAuthChallengeService: Запрашивает данные и способ аутентификация для `URLSession`.
    ///   При nil используется реализация на усмотрение `AcquiringSDK`
    /// - Returns: AcquiringSdkConfiguration
    public init(
        credential: AcquiringSdkCredential,
        server: AcquiringSdkEnvironment,
        requestsTimeoutInterval: TimeInterval = 40,
        logger: ILogger? = nil,
        tokenProvider: ITokenProvider? = nil,
        urlSessionAuthChallengeService: IURLSessionAuthChallengeService? = nil
    ) {
        self.credential = credential
        self.requestsTimeoutInterval = requestsTimeoutInterval
        self.logger = logger
        serverEnvironment = server
        configEnvironment = {
            switch server {
            case .prod, .custom: return .prod
            case .test, .preProd: return .test
            }
        }()
        self.tokenProvider = tokenProvider
        self.urlSessionAuthChallengeService = urlSessionAuthChallengeService
    }
}
