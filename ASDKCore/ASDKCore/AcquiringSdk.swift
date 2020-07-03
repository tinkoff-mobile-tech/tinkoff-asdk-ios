//
//  AcquiringSdk.swift
//  ASDKCore
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

public enum AcquiringSdkError: Error {
	
	case publicKey(String)
	
	case url
	
}


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

///
/// `AcquiringSdk`  позволяет конфигурировать SDK и осуществлять взаимодействие с **Тинькофф Эквайринг API**  https://oplata.tinkoff.ru/landing/develop/
public class AcquiringSdk: NSObject {

	public var fpsEnabled: Bool = false

	private var networkTransport: NetworkTransport
	private var terminalKey: String
	private var terminalPassword: String
	private var publicKey: SecKey
	public private(set) var languageKey: AcquiringSdkLanguage?
	private var logger: LoggerDelegate?
	
	/// Создает новый экземпляр SDK
	public init(configuration: AcquiringSdkConfiguration) throws {
		
		self.fpsEnabled = configuration.fpsEnabled

		self.terminalKey = configuration.credential.terminalKey
		self.terminalPassword = configuration.credential.password
		
		if let publicKey: SecKey = RSAEncryption.secKey(string: configuration.credential.publicKey) {
			self.publicKey = publicKey
		} else {
			throw AcquiringSdkError.publicKey(configuration.credential.publicKey)
		}
		
		if let url = URL.init(string: "https://\(configuration.serverEnvironment.rawValue)/") {
			let deviceInfo = DeviceInfo.init(model: UIDevice.current.localizedModel,
											 systemName: UIDevice.current.systemName,
											 systemVersion: UIDevice.current.systemVersion)
			
			self.networkTransport = AcquaringNetworkTransport.init(urlDomain: url, deviceInfo: deviceInfo)
		} else {
			throw AcquiringSdkError.url
		}
		
		self.languageKey = configuration.language
		self.logger = configuration.logger
		self.networkTransport.logger = logger
	}
	
	private func tokenParams(request: AcquiringRequestTokenParams & RequestOperation) -> JSONObject {
		var tokenParams: JSONObject = [:]
		tokenParams.updateValue(terminalKey, forKey: "TerminalKey")
		tokenParams.updateValue(terminalPassword, forKey: "Password")
		if let value = languageKey { tokenParams.updateValue(value, forKey: "Language") }

		tokenParams.merge(request.tokenParams()) { (_, new) -> JSONValue in new }

		let tokenSring: String = tokenParams.sorted(by: { (arg1, arg2) -> Bool in
			return arg1.key < arg2.key
		}).map { (item) -> String? in
			return String(describing: item.value)
		}.compactMap { $0 }.joined()

		tokenParams.updateValue(tokenSring.sha256(), forKey: "Token")
		tokenParams.removeValue(forKey: "Password")
		
		return tokenParams
	}
	
	/// Обновляем информцию о реквизитах карты, добавляем шифрование
	private func updateCardDataRequestParams(_ parameters: inout JSONObject?) {
		if let cardData = parameters?[PaymentFinishRequestData.CodingKeys.cardData.rawValue] as? String {
			if let encodedCardData = RSAEncryption.encrypt(string: cardData, publicKey: publicKey) {
				parameters?.updateValue(encodedCardData, forKey: PaymentFinishRequestData.CodingKeys.cardData.rawValue)
			}
		}
	}
	
	/// Получить IP адресс
	public func networkIpAddress() -> String? {
		return networkTransport.myIpAddress()
	}
	
	// MARK: - начало платежа
	
	/// Инициирует платежную сессию для платежа
	///
	/// - Parameters:
	///   - data: `PaymentInitPaymentData` информация о заказе на оплату
	///   - completionHandler: результат операции `PaymentInitResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func paymentInit(data: PaymentInitData, completionHandler: @escaping (_ result: Result<PaymentInitResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentInitRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	// MARK: - подтверждение платежа

	/// Создать запрос для подтвержения платежа 3ds формы
	///
	/// - Parameters:
	///   - data: `Confirmation3DSData`
	/// - Returns:
	///   - URLRequest
	public func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
		return try networkTransport.createConfirmation3DSRequest(requestData: data)
	}

	/// Создать запрос для подтвержения платежа 3ds формы
	///
	/// - Parameters:
	///   - data: `Confirmation3DSData`
	/// - Returns:
	///   - URLRequest
	public func createConfirmation3DSRequestACS(data: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest {
		return try networkTransport.createConfirmation3DSRequestACS(requestData: data, messageVersion: messageVersion)
	}
	
	/// Проверяет параметры для 3ds формы
	///
	/// - Parameters:
	///   - data: `Checking3DSURLData`
	/// - Returns:
	///   - URLRequest
	public func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
		return try networkTransport.createChecking3DSURL(requestData: data)
	}
	
	/// callback URL для завершения 3ds подтверждения
	///
	/// - Returns:
	///   - URL
	public func confirmation3DSTerminationURL() -> URL {
		return networkTransport.confirmation3DSTerminationURL
	}
	
	public func confirmation3DSTerminationV2URL() -> URL {
		return networkTransport.confirmation3DSTerminationV2URL
	}
	
	public func confirmation3DSCompleteV2URL() -> URL {
		return networkTransport.complete3DSMethodV2URL
	}
	
	/// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
	///
	/// - Parameters:
	///   - data: `PaymentFinishRequestData`
	///   - completionHandler: результат операции `Check3dsVersionResponse` в случае удачного ответа  и  `Error` - в случе ошибки.
	public func check3dsVersion(data: PaymentFinishRequestData, completionHandler: @escaping (_ result: Result<Check3dsVersionResponse, Error>) -> Void) -> Cancellable {
		let requestData = PaymentFinishRequestData.init(paymentId: data.paymentId, paymentSource: data.paymentSource)
		let request = Check3dsVersionRequest.init(data: requestData)
		updateCardDataRequestParams(&request.parameters)

		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }

		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	/// Подтверждает инициированный платеж передачей карточных данных
	///
	/// - Parameters:
	///   - data: `PaymentFinishRequestData`
	///   - completionHandler: результат операции `PaymentFinishResponse` в случае удачного проведеня платежа  и  `Error` - в случе ошибки.
	public func paymentFinish(data: PaymentFinishRequestData, completionHandler: @escaping (_ result: Result<PaymentFinishResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentFinishRequest.init(data: data)
		updateCardDataRequestParams(&request.parameters)
		
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}		
	}
	
	///
	/// Подтверждает инициированный платеж передачей рекуррентным платежом
	public func chargePayment(data: PaymentChargeRequestData, completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentChargeRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	// MARK: - Статус операции
	
	///
	/// Получить статус платежа
	public func paymentOperationStatus(data: PaymentInfoData, completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentStatusRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	// MARK: -
	
	///
	/// Отмена платежа
	/// - Parameters:
	///   - data: `PaymentInfoData` информация о оплатеже
	///   - completionHandler: результат операции `PaymentStatusResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func cancelPayment(data: PaymentInfoData, completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentCancelRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	// MARK: Cписок карт

	///
	/// - Parameters:
	///   - data: `InitGetCardListData` информация о клиенте для получения списка сохраненных карт
	///   - completionHandler: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func сardList(data: InitGetCardListData, responseDelegate: NetworkTransportResponseDelegate?, completionHandler: @escaping (_ result: Result<CardListResponse, Error>) -> Void) -> Cancellable {
		let request = CardListRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request, responseDelegate: responseDelegate) { result in
			completionHandler(result)
		}
	}
	
	///
	/// - Parameters:
	///   - data: `InitAddCardData` информация о клиенте и типе новой карты
	///   - completionHandler: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func сardListAddCardInit(data: InitAddCardData, completionHandler: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void) -> Cancellable {
		let request = InitAddCardRequest.init(requestData: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	///
	/// - Parameters:
	///   - data: `InitAddCardData` информация о клиенте и типе новой карты
	///   - completionHandler: результат операции `CardListResponse` в случае удачной регистрации карты и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func сardListAddCardFinish(data: FinishAddCardData, responseDelegate: NetworkTransportResponseDelegate?, completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void) -> Cancellable {
		let request = FinishAddCardRequest.init(requestData: data)
		updateCardDataRequestParams(&request.parameters)

		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request, responseDelegate: responseDelegate) { result in
			completionHandler(result)
		}
	}

	///
	/// - Parameters:
	///   - amount: `Double` сумма с копейками
	///   - requestKey: `String` ключ для привязки карты
	///   - completionHandler: результат операции `AddCardStatusResponse` в случае удачной регистрации карты и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func chechRandomAmount(_ amount: Double, requestKey: String, responseDelegate: NetworkTransportResponseDelegate?, completionHandler: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void) -> Cancellable {
		let request = CheckRandomAmountRequest.init(requestData: CheckingRandomAmountData.init(amount: amount, requestKey: requestKey))
		updateCardDataRequestParams(&request.parameters)
		
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request, responseDelegate: responseDelegate) { result in
			completionHandler(result)
		}
	}
	
	///
	/// - Parameters:
	///   - completionHandler: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func сardListDeactivateCard(data: InitDeactivateCardData, completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void) -> Cancellable {
		let request = InitDeactivateCardRequest.init(requestData: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	// MARK:  Система быстрых платежей, оплата по QR-коду
	
	/// Сгенерировать QR-код для оплаты
	///
	/// - Parameters:
	///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
	///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func paymentInvoiceQRCode(data: PaymentInvoiceQRCodeData, completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentInvoiceQRCodeRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
	/// Выставить счет / принять оплату, сгенерировать QR-код для принятия платежей
	///
	/// - Parameters:
	///   - data: `PaymentInvoiceQRCodeResponseType` информация о заказе на оплату
	///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
	/// - Returns: `Cancellable`
	public func paymentInvoiceQRCodeCollector(data: PaymentInvoiceSBPSourceType, completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeCollectorResponse, Error>) -> Void) -> Cancellable {
		let request = PaymentInvoiceQRCodeCollectorRequest.init(data: data)
		let requestTokenParams: JSONObject = tokenParams(request: request)
		request.parameters?.merge(requestTokenParams) { (_, new) -> JSONValue in new }
		
		return networkTransport.send(operation: request) { result in
			completionHandler(result)
		}
	}
	
}//AcquiringSdk
