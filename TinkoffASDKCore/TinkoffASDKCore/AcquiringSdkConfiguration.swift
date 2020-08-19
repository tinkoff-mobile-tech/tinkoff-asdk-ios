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
	public var password: String
	public var publicKey: String
	
	/// - Parameters:
	///   - terminalKey: ключ терминала. Выдается после подключения к **Тинькофф Эквайринг API**
	///   - password: пароль от терминала. Выдается вместе с `terminalKey`
	///   - publicKey: публичный ключ. Выдается вместе с `terminalKey`
	/// - Returns: AcquiringSdkCredential
	public init(terminalKey: String, password: String, publicKey: String) {
		self.terminalKey = terminalKey
		self.password = password
		self.publicKey = publicKey
	}
	
}


/// Кофигурация для экземпляра SDK
public class AcquiringSdkConfiguration: NSObject {
	
	public var fpsEnabled: Bool = false
	
	public private(set) var credential: AcquiringSdkCredential
	
	public private(set) var serverEnvironment: AcquiringSdkEnvironment
	
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
	/// - Returns: AcquiringSdkConfiguration
	public init(credential: AcquiringSdkCredential, server: AcquiringSdkEnvironment = .test) {
		self.credential = credential
		self.serverEnvironment = server
	}
	
}
