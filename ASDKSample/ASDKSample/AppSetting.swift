//
//
//  AppSetting.swift
//
//  Copyright (c) 2021 Tinkoff Bank
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
import UIKit

final class AppSetting {

    static let shared = AppSetting()

    // MARK: - User Defaults Values

    /// Система быстрых платежей
    var paySBP = false {
        didSet {
            UserDefaults.standard.set(paySBP, forKey: .keySBP)
        }
    }

    /// Текущая активная схема Credentials для SDK
    var activeSdkCredentials: SdkCredentials {
        get {
            let result = try? formGetter(key: .keySdkCredentials, defaultValue: SdkCredentials.test)
            if result == nil {
                self.activeSdkCredentials = .test
            }

            return result ?? .test
        }
        set {
            try? formSetter(key: .keySdkCredentials, valueToEncode: newValue)
        }
    }

    /// Список сохраненных Sdk Credentials
    var listOfSdkCredentials: [SdkCredentials] {
        get {
            let result = try? formGetter(key: .keyListSdkCredentials, defaultValue: [SdkCredentials].testTerminals)
            if result == nil {
                self.listOfSdkCredentials = .testTerminals
            }
            return result ?? .testTerminals
        }

        set {
            try? formSetter(key: .keyListSdkCredentials, valueToEncode: newValue)
        }
    }

    /// TinkoffPay
    var tinkoffPay = false {
        didSet {
            UserDefaults.standard.set(tinkoffPay, forKey: .keyTinkoffPay)
        }
    }

    /// Показыть на форме оплаты поле для ввода email для отправки чека
    var showEmailField = false {
        didSet {
            UserDefaults.standard.set(showEmailField, forKey: .keyShowEmailField)
        }
    }

    var acquiring = false {
        didSet {
            UserDefaults.standard.set(acquiring, forKey: .keyKindForAlertView)
        }
    }

    var addCardChekType: PaymentCardCheckType = .no {
        didSet {
            UserDefaults.standard.set(addCardChekType.rawValue, forKey: .keyAddCardCheckType)
        }
    }

    var serverType: AcquiringSdkEnvironment = .test {
        didSet {
            UserDefaults.standard.set(serverType.rawValue, forKey: .keyServerType)
        }
    }

    var customServer: String? {
        didSet {
            UserDefaults.standard.set(customServer, forKey: .keyCustomServer)
        }
    }

    var languageId: String? {
        didSet {
            UserDefaults.standard.set(languageId, forKey: .keyLanguageId)
        }
    }

    /// Используется для отключения анимаций в тестах
    var setAnimationsEnabled = true {
        willSet {
            UIView.setAnimationsEnabled(newValue)
        }
    }

    // MARK: - Init

    private init() {
        let userDefaults = UserDefaults.standard

        paySBP = userDefaults.bool(forKey: .keySBP)
        tinkoffPay = userDefaults.bool(forKey: .keyTinkoffPay)
        showEmailField = userDefaults.bool(forKey: .keyShowEmailField)
        acquiring = userDefaults.bool(forKey: .keyKindForAlertView)
        if let value = userDefaults.string(forKey: .keyAddCardCheckType) {
            addCardChekType = PaymentCardCheckType(rawValue: value)
        }

        if let value = userDefaults.string(forKey: .keyServerType) {
            serverType = AcquiringSdkEnvironment(rawValue: value)
        }

        customServer = userDefaults.string(forKey: .keyCustomServer)

        languageId = userDefaults.string(forKey: .keyLanguageId)
    }
}

extension AppSetting {

    enum Error: Swift.Error {
        case couldntFormData
        case couldntFormJsonString
    }

    private func formGetter<T: Decodable>(key: String, defaultValue: T) throws -> T {
        let jsonString = UserDefaults.standard.string(forKey: key)
        let decoder = JSONDecoder()

        guard let jsonString = jsonString else {
            return defaultValue
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw Error.couldntFormData
        }

        return try decoder.decode(T.self, from: data)
    }

    private func formSetter<T: Encodable>(key: String, valueToEncode: T) throws {
        let encoder = JSONEncoder()

        let data = try encoder.encode(valueToEncode)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw Error.couldntFormJsonString
        }

        UserDefaults.standard.set(jsonString, forKey: key)
    }
}

private extension String {
    static let keySBP = "SettingKeySBP"
    static let keyTinkoffPay = "SettingKeyTinkoffPay"
    static let keyShowEmailField = "SettingKeyShowEmailField"
    static let keyKindForAlertView = "KindForAlertView"
    static let keyAddCardCheckType = "AddCardChekType"
    static let keyServerType = "ServerType"
    static let keyCustomServer = "CustomServer"
    static let keyLanguageId = "LanguageId"
    static let keySdkCredentials = "keySdkCredentials"
    static let keyListSdkCredentials = "keyListSdkCredentials"
}
