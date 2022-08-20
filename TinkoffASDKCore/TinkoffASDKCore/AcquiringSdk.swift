//
//  AcquiringSdk.swift
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

public enum AcquiringSdkError: Error {
    case publicKey(String)

    case url
}

///
/// `AcquiringSdk`  позволяет конфигурировать SDK и осуществлять взаимодействие с **Тинькофф Эквайринг API**  https://oplata.tinkoff.ru/landing/develop/
public final class AcquiringSdk: NSObject {
    public var fpsEnabled: Bool = false

    private var networkTransport: NetworkTransport
    private var terminalKey: String
    private var publicKey: SecKey
    public private(set) var languageKey: AcquiringSdkLanguage?
    private var logger: LoggerDelegate?

    /// Создает новый экземпляр SDK
    public init(configuration: AcquiringSdkConfiguration) throws {
        fpsEnabled = configuration.fpsEnabled

        terminalKey = configuration.credential.terminalKey

        if let publicKey: SecKey = RSAEncryption.secKey(string: configuration.credential.publicKey) {
            self.publicKey = publicKey
        } else {
            throw AcquiringSdkError.publicKey(configuration.credential.publicKey)
        }

        if let url = URL(string: "https://\(configuration.serverEnvironment.rawValue)/"),
           let certsConfigUrl = URL(string: "https://\(configuration.configEnvironment.rawValue)/") {
            let deviceInfo = DeviceInfo(model: UIDevice.current.localizedModel,
                                        systemName: UIDevice.current.systemName,
                                        systemVersion: UIDevice.current.systemVersion)

            let sessionConfiguration = URLSessionConfiguration.default
            sessionConfiguration.timeoutIntervalForRequest = configuration.requestsTimeoutInterval
            sessionConfiguration.timeoutIntervalForResource = configuration.requestsTimeoutInterval
            
            networkTransport = AcquaringNetworkTransport(urlDomain: url,
                                                         certsConfigDomain: certsConfigUrl,
                                                         session: URLSession(configuration: sessionConfiguration),
                                                         deviceInfo: deviceInfo)
        } else {
            throw AcquiringSdkError.url
        }

        languageKey = configuration.language
        logger = configuration.logger
        networkTransport.logger = logger
    }

    private func createCommonParameters() -> JSONObject {
        var parameters: JSONObject = [:]
        parameters.updateValue(terminalKey, forKey: "TerminalKey")
        if let value = languageKey { parameters.updateValue(value, forKey: "Language") }

        return parameters
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
        let paramsEnricher: IPaymentInitDataParamsEnricher = PaymentInitDataParamsEnricher()
        let enrichedData = paramsEnricher.enrich(data)
        
        let request = PaymentInitRequest(data: enrichedData)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

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
    ///   - completionHandler: результат операции `Check3dsVersionResponse` в случае удачного ответа и `Error` - в случе ошибки.
    public func check3dsVersion(data: PaymentFinishRequestData, completionHandler: @escaping (_ result: Result<Check3dsVersionResponse, Error>) -> Void) -> Cancellable {
        let requestData = PaymentFinishRequestData(paymentId: data.paymentId, paymentSource: data.paymentSource)
        let request = Check3dsVersionRequest(data: requestData)
        updateCardDataRequestParams(&request.parameters)

        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request) { result in
            completionHandler(result)
        }
    }

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `PaymentFinishResponse` в случае удачного проведеня платежа и `Error` - в случе ошибки.
    public func paymentFinish(data: PaymentFinishRequestData, completionHandler: @escaping (_ result: Result<PaymentFinishResponse, Error>) -> Void) -> Cancellable {
        let request = PaymentFinishRequest(data: data)
        updateCardDataRequestParams(&request.parameters)

        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request) { result in
            completionHandler(result)
        }
    }

    ///
    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    public func chargePayment(data: PaymentChargeRequestData, completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void) -> Cancellable {
        let request = PaymentChargeRequest(data: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request) { result in
            completionHandler(result)
        }
    }

    // MARK: - Статус операции

    ///
    /// Получить статус платежа
    public func paymentOperationStatus(data: PaymentInfoData, completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void) -> Cancellable {
        let request = PaymentStatusRequest(data: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request) { result in
            completionHandler(result)
        }
    }

    // MARK: - Cписок карт

    ///
    /// - Parameters:
    ///   - data: `InitGetCardListData` информация о клиенте для получения списка сохраненных карт
    ///   - completionHandler: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func сardList(data: InitGetCardListData, responseDelegate: NetworkTransportResponseDelegate?, completionHandler: @escaping (_ result: Result<CardListResponse, Error>) -> Void) -> Cancellable {
        let request = CardListRequest(data: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

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
        let request = InitAddCardRequest(requestData: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

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
        let request = FinishAddCardRequest(requestData: data)
        updateCardDataRequestParams(&request.parameters)

        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

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
        let request = CheckRandomAmountRequest(requestData: CheckingRandomAmountData(amount: amount, requestKey: requestKey))
        updateCardDataRequestParams(&request.parameters)

        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request, responseDelegate: responseDelegate) { result in
            completionHandler(result)
        }
    }

    ///
    /// - Parameters:
    ///   - completionHandler: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func сardListDeactivateCard(data: InitDeactivateCardData, completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void) -> Cancellable {
        let request = InitDeactivateCardRequest(requestData: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request) { result in
            completionHandler(result)
        }
    }

    // MARK: - Система быстрых платежей, оплата по QR-коду

    /// Сгенерировать QR-код для оплаты
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInvoiceQRCode(data: PaymentInvoiceQRCodeData, completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeResponse, Error>) -> Void) -> Cancellable {
        let request = PaymentInvoiceQRCodeRequest(data: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

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
        let request = PaymentInvoiceQRCodeCollectorRequest(data: data)
        let commonParameters: JSONObject = createCommonParameters()
        request.parameters?.merge(commonParameters) { (_, new) -> JSONValue in new }

        return networkTransport.send(operation: request) { result in
            completionHandler(result)
        }
    }
    
    /// Загрузить список банков, через приложения которых можно совершить оплату СБП
    ///
    /// - Parameters:
    ///   - completion: результат запроса. `SBPBankResponse` в случае успешного запроса и  `Error` - ошибка.
    
    public func loadSBPBanks(completion: @escaping (Result<SBPBankResponse, Error>) -> Void) {
        let loader = DefaultSBPBankLoader()
        loader.loadBanks(completion: completion)
    }
    
    ///
    
    public func getTinkoffPayStatus(completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void) -> Cancellable {
        let request = GetTinkoffPayStatusRequest(terminalKey: terminalKey)
        return networkTransport.send(operation: request) { result in
            completion(result)
        }
    }
    
    public func getTinkoffPayLink(paymentId: Int64,
                                  version: GetTinkoffPayStatusResponse.Status.Version,
                                  completion: @escaping (Result<GetTinkoffLinkResponse, Error>) -> Void) -> Cancellable {
        let request = GetTinkoffLinkRequest(paymentId: paymentId,
                                            version: version)
        return networkTransport.send(operation: request) { result in
            completion(result)
        }
    }
    
    @discardableResult
    public func getCertsConfig(completion: @escaping (Result<GetCertsConfigResponse, Error>) -> Void) -> Cancellable {
        let request = GetCertsConfigRequest()
        return networkTransport.sendCertsConfigRequest(operation: request, completionHandler: completion)
    }
    
    @discardableResult
    public func submit3DSAuthorizationV2(cres: String,
                                         completion: @escaping (Result<PaymentStatusResponse, Error>) -> Void) -> Cancellable {
        let cresData = CresData(cres: cres)
        let request = ThreeDSV2AuthorizationRequest(data: cresData)
        return networkTransport.send(operation: request, completionHandler: completion)
    }
} // AcquiringSdk
