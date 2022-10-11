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

protocol ActiveCredentialsListener: AnyObject {
    func activeCredentialsSetNew(creds: SdkCredentials)
}

final class AppSetting {

    private var activeCredenetialslisteners: [() -> ActiveCredentialsListener?] = []

    private let keySBP = "SettingKeySBP"
    private let keyTinkoffPay = "SettingKeyTinkoffPay"
    private let keyShowEmailField = "SettingKeyShowEmailField"
    private let keyKindForAlertView = "KindForAlertView"
    private let keyAddCardCheckType = "AddCardChekType"
    private let keyLanguageId = "LanguageId"
    private let keySdkCredentials = "keySdkCredentials"
    private let listKeySdkCredentials = "listKeySdkCredentials"

    /// Система быстрых платежей
    var paySBP = false {
        didSet {
            UserDefaults.standard.set(paySBP, forKey: keySBP)
            UserDefaults.standard.synchronize()
        }
    }

    ///
    var activeSdkCredentials: SdkCredentials {
        get {
            let jsonString = UserDefaults.standard.string(forKey: keySdkCredentials)
            let decoder = JSONDecoder()

            guard let jsonString = jsonString,
                  let data = jsonString.data(using: .utf8),
                  let creds = try? decoder.decode(SdkCredentials.self, from: data) else {
                self.activeSdkCredentials = .test
                return .test
            }

            return creds
        }
        set {
            let encoder = JSONEncoder()

            guard let data = try? encoder.encode(newValue),
                  let jsonString = String(data: data, encoding: .utf8) else {
                return
            }

            UserDefaults.standard.set(jsonString, forKey: keySdkCredentials)
            notifyListenersAboutActiveCredentialsChange(newActiveCreds: newValue)
        }
    }

    ///
    var listOfSdkCredentials: [SdkCredentials] {
        get {
            let jsonString = UserDefaults.standard.string(forKey: listKeySdkCredentials)
            let decoder = JSONDecoder()
            guard let data = jsonString?.data(using: .utf8) else {
                return [activeSdkCredentials]
            }

            guard var creds = try? decoder.decode([SdkCredentials].self, from: data) else {
                return []
            }

            if creds.isEmpty {
                creds.append(activeSdkCredentials)
            }

            return creds
        }

        set {
            let encoder = JSONEncoder()
            guard let encodedData = try? encoder.encode(newValue) else {
                return
            }
            let jsonString = String(data: encodedData, encoding: .utf8)
            UserDefaults.standard.set(jsonString, forKey: listKeySdkCredentials)
        }
    }

    /// TinkoffPay
    var tinkoffPay = false {
        didSet {
            UserDefaults.standard.set(tinkoffPay, forKey: keyTinkoffPay)
        }
    }

    /// Показыть на форме оплаты поле для ввода email для отправки чека
    var showEmailField = false {
        didSet {
            UserDefaults.standard.set(showEmailField, forKey: keyShowEmailField)
            UserDefaults.standard.synchronize()
        }
    }

    var acquiring = false {
        didSet {
            UserDefaults.standard.set(acquiring, forKey: keyKindForAlertView)
            UserDefaults.standard.synchronize()
        }
    }

    var addCardChekType: PaymentCardCheckType = .no {
        didSet {
            UserDefaults.standard.set(addCardChekType.rawValue, forKey: keyAddCardCheckType)
            UserDefaults.standard.synchronize()
        }
    }

    var languageId: String? {
        didSet {
            UserDefaults.standard.set(languageId, forKey: keyLanguageId)
            UserDefaults.standard.synchronize()
        }
    }

    static let shared = AppSetting()

    private init() {
        let usd = UserDefaults.standard

        paySBP = usd.bool(forKey: keySBP)
        tinkoffPay = usd.bool(forKey: keyTinkoffPay)
        showEmailField = usd.bool(forKey: keyShowEmailField)
        acquiring = usd.bool(forKey: keyKindForAlertView)
        if let value = usd.value(forKey: keyAddCardCheckType) as? String {
            addCardChekType = PaymentCardCheckType(rawValue: value)
        }

        languageId = usd.string(forKey: keyLanguageId)
    }
}

extension AppSetting {

    func addListener(_ listener: ActiveCredentialsListener) {
        activeCredenetialslisteners.append { [weak listener] in
            listener
        }
    }

    func removeListener(_ listener: ActiveCredentialsListener) {
        activeCredenetialslisteners.removeAll(where: {
            $0() === listener
        })
    }

    func notifyListenersAboutActiveCredentialsChange(newActiveCreds: SdkCredentials) {
        activeCredenetialslisteners.forEach {
            $0()?.activeCredentialsSetNew(creds: newActiveCreds)
        }
    }
}
