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

/// `AcquiringSdk`  позволяет конфигурировать SDK и осуществлять взаимодействие с **Тинькофф Эквайринг API**  https://oplata.tinkoff.ru/landing/develop/
public final class AcquiringSdk: NSObject {
    @available(*, deprecated, message: "Property does not affect anything")
    public var fpsEnabled: Bool = false
    public let languageKey: AcquiringSdkLanguage?
    private let terminalKey: String
    private let publicKey: SecKey
    private let baseURL: URL
    private let certsConfigUrl: URL

    private let coreAssembly: CoreAssembly
    private let api: API

    /// Создает новый экземпляр SDK
    public init(configuration: AcquiringSdkConfiguration) throws {
        self.terminalKey = configuration.credential.terminalKey
        self.languageKey = configuration.language

        if let publicKey: SecKey = RSAEncryption.secKey(string: configuration.credential.publicKey) {
            self.publicKey = publicKey
        } else {
            throw AcquiringSdkError.publicKey(configuration.credential.publicKey)
        }

        coreAssembly = CoreAssembly(configuration: configuration)
        api = coreAssembly.buildAPI()

        if let url = URL(string: "https://\(configuration.serverEnvironment.rawValue)/"),
           let certsConfigUrl = URL(string: "https://\(configuration.configEnvironment.rawValue)/") {
            self.baseURL = url
            self.certsConfigUrl = certsConfigUrl
        } else {
            throw AcquiringSdkError.url
        }
    }

    private func createCommonParameters() -> JSONObject {
        var parameters: JSONObject = [:]
        parameters.updateValue(terminalKey, forKey: "TerminalKey")
        if let value = languageKey { parameters.updateValue(value, forKey: "Language") }

        return parameters
    }

    /// Обновляем информацию о реквизитах карты, добавляем шифрование
    private func updateCardDataRequestParams(_ parameters: inout JSONObject?) {
        if let cardData = parameters?[PaymentFinishRequestData.CodingKeys.cardData.rawValue] as? String {
            if let encodedCardData = RSAEncryption.encrypt(string: cardData, publicKey: publicKey) {
                parameters?.updateValue(encodedCardData, forKey: PaymentFinishRequestData.CodingKeys.cardData.rawValue)
            }
        }
    }

    /// Получить IP адрес
    public func networkIpAddress() -> IPAddress? {
        return coreAssembly.ipAddressProvider().ipAddress
    }

    // MARK: - подтверждение платежа

    /// Создать запрос для подтверждения платежа 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    public func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
        try coreAssembly.threeDSURLRequestBuilder().buildConfirmation3DSRequest(requestData: data)
    }

    /// Создать запрос для подтверждения платежа 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    public func createConfirmation3DSRequestACS(
        data: Confirmation3DSDataACS,
        messageVersion: String
    ) throws -> URLRequest {
        try coreAssembly.threeDSURLRequestBuilder().buildConfirmation3DSRequestACS(requestData: data, version: messageVersion)
    }

    /// Проверяет параметры для 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Checking3DSURLData`
    /// - Returns:
    ///   - URLRequest
    public func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
        try coreAssembly.threeDSURLRequestBuilder().build3DSCheckURLRequest(requestData: data)
    }

    /// callback URL для завершения 3DS подтверждения
    ///
    /// - Returns:
    ///   - URL
    public func confirmation3DSTerminationURL() throws -> URL {
        try coreAssembly.threeDSURLBuilder().buildURL(type: .confirmation3DSTerminationURL)
    }

    public func confirmation3DSTerminationV2URL() throws -> URL {
        try coreAssembly.threeDSURLBuilder().buildURL(type: .confirmation3DSTerminationV2URL)
    }

    public func confirmation3DSCompleteV2URL() throws -> URL {
        try coreAssembly.threeDSURLBuilder().buildURL(type: .threeDSCheckNotificationURL)
    }

    public func payment3DSHandler() -> ThreeDSWebViewHandler<GetPaymentStatePayload> {
        return coreAssembly.threeDSWebViewHandler()
    }
    
    public func addCard3DSHandler() -> ThreeDSWebViewHandler<AttachCardPayload> {
        return coreAssembly.threeDSWebViewHandler()
    }
    
    public func threeDSDeviceParamsProvider(screenSize: CGSize) -> ThreeDSDeviceParamsProvider {
        return coreAssembly.threeDSDeviceParamsProvider(screenSize: screenSize, language: languageKey ?? .ru)
    }

    // MARK: Payment Init

    /// Инициирует платежную сессию для платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInitPaymentData` информация о заказе на оплату
    ///   - completionHandler: результат операции `InitPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInit(
        data: PaymentInitData,
        completionHandler: @escaping (_ result: Result<InitPayload, Error>) -> Void
    ) -> Cancellable {
        let paramsEnricher: IPaymentInitDataParamsEnricher = PaymentInitDataParamsEnricher()
        let enrichedData = paramsEnricher.enrich(data)
        let request = InitRequest(paymentInitData: enrichedData, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// Инициирует платежную сессию для платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInitPaymentData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInitResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable
    @available(*, deprecated, message: "Use paymentInit(data:completionHandler:) instead")
    public func paymentInit(
        data: PaymentInitData,
        completionHandler: @escaping (_ result: Result<PaymentInitResponse, Error>) -> Void
    ) -> Cancellable {
        let paramsEnricher: IPaymentInitDataParamsEnricher = PaymentInitDataParamsEnricher()
        let enrichedData = paramsEnricher.enrich(data)
        let request = InitRequest(paymentInitData: enrichedData, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Payment Finish

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `FinishAuthorizePayload` в случае удачного проведеня платежа и `Error` - в случе ошибки.
    public func paymentFinish(
        data: PaymentFinishRequestData,
        completionHandler: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void
    ) -> Cancellable {
        let request = FinishAuthorizeRequest(
            paymentFinishRequestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )

        return api.performRequest(request, completion: completionHandler)
    }

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `PaymentFinishResponse` в случае удачного проведения платежа и `Error` - в случае ошибки.
    @available(*, deprecated, message: "Use paymentFinish(data:completionHandler:) instead")
    @discardableResult
    public func paymentFinish(
        data: PaymentFinishRequestData,
        completionHandler: @escaping (_ result: Result<PaymentFinishResponse, Error>) -> Void
    ) -> Cancellable {
        let request = FinishAuthorizeRequest(
            paymentFinishRequestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )
        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Check 3DS Version

    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `Check3DSRequestData`
    ///   - completionHandler: результат операции `Check3DSVersionPayload` в случае удачного ответа и `Error` - в случе ошибки.
    public func check3dsVersion(
        data: Check3DSRequestData,
        completionHandler: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void
    ) -> Cancellable {
        let request = Check3DSVersionRequest(
            check3DSRequestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )
        
        return api.performRequest(request, completion: completionHandler)
    }

    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `Check3dsVersionResponse` в случае удачного ответа и `Error` - в случае ошибки.
    @available(*, deprecated, message: "Use check3dsVersion(data:completionHandler:) instead")
    @discardableResult
    public func check3dsVersion(
        data: PaymentFinishRequestData,
        completionHandler: @escaping (_ result: Result<Check3dsVersionResponse, Error>) -> Void
    ) -> Cancellable {
        let requestData = Check3DSRequestData(paymentId: data.paymentId, paymentSource: data.paymentSource)
        let request = Check3DSVersionRequest(
            check3DSRequestData: requestData,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )

        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Submit 3DS Authorization V2

    @discardableResult
    public func submit3DSAuthorizationV2(
        cres: String,
        completion: @escaping (Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let cresData = CresData(cres: cres)
        let request = ThreeDSV2AuthorizationRequest(data: cresData, baseURL: baseURL)
        return api.performDeprecatedRequest(request, completion: completion)
    }

    // MARK: Payment Operation Status

    /// Получить статус платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInfoData`
    ///   - completionHandler: результат операции `GetPaymentStatePayload` в случае удачного ответа и `Error` - в случе ошибки.
    public func paymentOperationStatus(
        data: PaymentInfoData,
        completionHandler: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetPaymentStateRequest(paymentInfoData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// Получить статус платежа
    @available(*, deprecated, message: "Use paymentOperationStatus(data:completionHandler:) instead")
    @discardableResult
    public func paymentOperationStatus(
        data: PaymentInfoData,
        completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetPaymentStateRequest(paymentInfoData: data, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Charge Payment

    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    ///
    /// - Parameters:
    ///   - data: `PaymentChargeRequestData`
    ///   - completionHandler: результат операции `ChargePaymentPayload` в случае удачного ответа и `Error` - в случе ошибки.
    public func chargePayment(
        data: PaymentChargeRequestData,
        completionHandler: @escaping (_ result: Result<ChargePaymentPayload, Error>) -> Void
    ) -> Cancellable {
        let request = ChargePaymentRequest(paymentChargeRequestData: data, baseURL: baseURL)
        return api.performRequest(request, completion: completionHandler)
    }

    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    @available(*, deprecated, message: "Use chargePayment(data:completionHandler:) instead")
    @discardableResult
    public func chargePayment(
        data: PaymentChargeRequestData,
        completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = ChargePaymentRequest(paymentChargeRequestData: data, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Get Card List
    
    /// Получение всех сохраненных карт клиента
    ///
    /// - Parameters:
    ///   - data: `GetCardListData` информация о клиенте для получения списка сохраненных карт
    ///   - completionHandler: результат операции `[PaymentCard]` в случае успешного запроса и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func cardList(
        data: GetCardListData,
        completionHandler: @escaping (_ result: Result<[PaymentCard], Error>) -> Void
    ) -> Cancellable {
        let request = GetCardListRequest(getCardListData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// - Parameters:
    ///   - data: `InitGetCardListData` информация о клиенте для получения списка сохраненных карт
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use cardList(data:completionHandler:) instead")
    @discardableResult
    public func cardList(
        data: InitGetCardListData,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<CardListResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetCardListRequest(getCardListData: GetCardListData(customerKey: data.customerKey), baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    @available(*, deprecated, renamed: "cardList(data:responseDelegate:completion:)")
    public func сardList(
        data: InitGetCardListData,
        responseDelegate: NetworkTransportResponseDelegate?,
        completionHandler: @escaping (_ result: Result<CardListResponse, Error>) -> Void
    ) -> Cancellable {
        cardList(data: data, responseDelegate: responseDelegate, completion: completionHandler)
    }

    // MARK: Add Card Init

    /// Инициирует привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе привязки карты
    ///   - completionHandler: результат операции `AddCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func addCardInit(
        data: InitAddCardData,
        completionHandler: @escaping (_ result: Result<AddCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = AddCardRequest(initAddCardData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use addCardInit(data:completionHandler:) instead")
    @discardableResult
    public func cardListAddCardInit(
        data: InitAddCardData,
        completion: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = AddCardRequest(initAddCardData: data, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    @available(*, deprecated, renamed: "cardListAddCardInit(data:completion:)")
    public func сardListAddCardInit(
        data: InitAddCardData,
        completionHandler: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListAddCardInit(data: data, completion: completionHandler)
    }

    // MARK: Add Card Finish

    /// Завершает привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `FinishAddCardData` информация о карте
    ///   - completionHandler: результат операции `AttachCardPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func addCardFinish(
        data: FinishAddCardData,
        completionHandler: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = AttachCardRequest(
            finishAddCardData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )

        return api.performRequest(request, completion: completionHandler)
    }

    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use addCardFinish(data:completionHandler:) instead")
    @discardableResult
    public func cardListAddCardFinish(
        data: FinishAddCardData,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = AttachCardRequest(
            finishAddCardData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )

        return api.performDeprecatedRequest(request, completion: completion)
    }

    @available(*, deprecated, renamed: "cardListAddCardFinish(data:responseDelegate:completion:)")
    public func сardListAddCardFinish(
        data: FinishAddCardData,
        responseDelegate: NetworkTransportResponseDelegate?,
        completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListAddCardFinish(
            data: data,
            responseDelegate: responseDelegate,
            completion: completionHandler
        )
    }

    // MARK: Check Random Amount

    /// Подтверждения карты путем блокировки случайной суммы
    ///
    /// - Parameters:
    ///   - data: `SubmitRandomAmountData`
    ///   - completionHandler: результат операции `SubmitRandomAmountPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func checkRandomAmount(
        data: SubmitRandomAmountData,
        completionHandler: @escaping (_ result: Result<SubmitRandomAmountPayload, Error>) -> Void
    ) -> Cancellable {
        let request = SubmitRandomAmountRequest(submitRandomAmountData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// - Parameters:
    ///   - amount: `Double` сумма с копейками
    ///   - requestKey: `String` ключ для привязки карты
    ///   - completion: результат операции `AddCardStatusResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use checkRandomAmount(data:completionHandler:) instead")
    @discardableResult
    public func checkRandomAmount(
        _ amount: Double,
        requestKey: String,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = SubmitRandomAmountRequest(submitRandomAmountData: .init(amount: Int64(amount), requestKey: requestKey), baseURL: baseURL)
        return api.performDeprecatedRequest(request, delegate: responseDelegate, completion: completion)
    }

    @available(*, deprecated, renamed: "checkRandomAmount(_:requestKey:responseDelegate:completion:)")
    public func chechRandomAmount(
        _ amount: Double,
        requestKey: String,
        responseDelegate: NetworkTransportResponseDelegate?,
        completionHandler: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void
    ) -> Cancellable {
        checkRandomAmount(
            amount,
            requestKey: requestKey,
            responseDelegate: responseDelegate,
            completion: completionHandler
        )
    }

    // MARK: Deactivate Card

    /// Удаление привязанной карты покупателя
    ///
    /// - Parameters:
    ///     - completionHandler: результат операции `RemoveCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func deactivateCard(
        data: InitDeactivateCardData,
        completionHandler: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = RemoveCardRequest(deactivateCardData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// - Parameters:
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use deactivateCard(data:completionHandler:) instead")
    @discardableResult
    public func cardListDeactivateCard(
        data: InitDeactivateCardData,
        completion: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = RemoveCardRequest(deactivateCardData: data, baseURL: baseURL)
        return api.performDeprecatedRequest(request, completion: completion)
    }

    @available(*, deprecated, renamed: "cardListDeactivateCard(data:completion:)")
    public func сardListDeactivateCard(
        data: InitDeactivateCardData,
        completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListDeactivateCard(data: data, completion: completionHandler)
    }
    
    // MARK: Payment Invoice QR Code
    
    /// Сгенерировать QR-код для оплаты
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
    ///   - completionHandler: результат операции `GetQrPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInvoiceQRCode(
        data: PaymentInvoiceQRCodeData,
        completionHandler: @escaping (_ result: Result<GetQrPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetQrRequest(data: data, baseURL: baseURL)

        return api.performRequest(request, completion: completionHandler)
    }

    /// Сгенерировать QR-код для оплаты
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use paymentInvoiceQRCode(data:completionHandler:) instead")
    @discardableResult
    public func paymentInvoiceQRCode(
        data: PaymentInvoiceQRCodeData,
        completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetQrRequest(data: data, baseURL: baseURL)
        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Payment Invoice QR Code Collector

    /// Выставить счет / принять оплату, сгенерировать QR-код для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceSBPSourceType` тип возвращаемых данных для генерации QR-кода
    ///   - completionHandler: результат операции `GetStaticQrPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInvoiceQRCodeCollector(
        data: PaymentInvoiceSBPSourceType,
        completionHandler: @escaping (_ result: Result<GetStaticQrPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetStaticQrRequest(sourceType: data, baseURL: baseURL)
        return api.performRequest(request, completion: completionHandler)
    }

    /// Выставить счет / принять оплату, сгенерировать QR-код для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeResponseType` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @available(*, deprecated, message: "Use paymentInvoiceQRCodeCollector(data:completionHandler:) instead")
    @discardableResult
    public func paymentInvoiceQRCodeCollector(
        data: PaymentInvoiceSBPSourceType,
        completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeCollectorResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetStaticQrRequest(sourceType: data, baseURL: baseURL)
        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Load SBP Banks

    /// Загрузить список банков, через приложения которых можно совершить оплату СБП
    ///
    /// - Parameters:
    ///   - completion: результат запроса. `SBPBankResponse` в случае успешного запроса и  `Error` - ошибка.
    public func loadSBPBanks(completion: @escaping (Result<SBPBankResponse, Error>) -> Void) {
        let loader = DefaultSBPBankLoader()
        loader.loadBanks(completion: completion)
    }

    // MARK: Get TinkoffPay Status

    @discardableResult
    public func getTinkoffPayStatus(
        completion: @escaping (Result<GetTinkoffPayStatusPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetTinkoffPayStatusRequest(terminalKey: terminalKey, baseURL: baseURL)
        return api.performRequest(request, completion: completion)
    }

    @available(*, deprecated, message: "Use getTinkoffPayStatus(completionHandler:) instead")
    @discardableResult
    public func getTinkoffPayStatus(
        completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetTinkoffPayStatusRequest(terminalKey: terminalKey, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    // MARK: Get TinkoffPay Link

    @discardableResult
    public func getTinkoffPayLink(
        paymentId: PaymentId,
        version: GetTinkoffPayStatusPayload.Status.Version,
        completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetTinkoffLinkRequest(paymentId: paymentId, version: version, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    // MARK: Get Certs Config

    @discardableResult
    public func getCertsConfig(completion: @escaping (Result<GetCertsConfigPayload, Error>) -> Void) -> Cancellable {
        let request = GetCertsConfigRequest(baseURL: certsConfigUrl)
        return api.performRequest(request, completion: completion)
    }

    @available(*, deprecated, message: "Use getCertsConfig(completionHandler:) instead")
    @discardableResult
    public func getCertsConfig(completion: @escaping (Result<GetCertsConfigResponse, Error>) -> Void) -> Cancellable {
        let request = GetCertsConfigRequest(baseURL: certsConfigUrl)
        return api.sendCertsConfigRequest(request, completionHandler: completion)
    }
}
