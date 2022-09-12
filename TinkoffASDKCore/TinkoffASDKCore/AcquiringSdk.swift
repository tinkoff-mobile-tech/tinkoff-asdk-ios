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
    public let languageKey: AcquiringSdkLanguage?
    private let terminalKey: String
    private let publicKey: SecKey
    private let baseURL: URL
    private let certsConfigUrl: URL
    @available(*, deprecated, message: "Property does not affect anything")
    public var fpsEnabled: Bool = false

    private let coreAssembly: CoreAssembly
    private let api: API

    /// Текущий IP адрес
    public var ipAddress: IPAddress? {
        coreAssembly.ipAddressProvider().ipAddress
    }

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

    /// Получить IP адрес
    @available(*, deprecated, message: "Use AcquiringSdk.ipAddress instead")
    public func networkIpAddress() -> String? {
        return coreAssembly.ipAddressProvider().ipAddress?.stringValue
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

    // MARK: Init Payment

    /// Инициирует платежную сессию для платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInitData` информация о заказе на оплату
    ///   - completion: результат операции `InitPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func initPayment(
        data: PaymentInitData,
        completion: @escaping (_ result: Result<InitPayload, Error>) -> Void
    ) -> Cancellable {
        let paramsEnricher: IPaymentInitDataParamsEnricher = PaymentInitDataParamsEnricher()
        let enrichedData = paramsEnricher.enrich(data)
        let request = InitRequest(paymentInitData: enrichedData, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// Инициирует платежную сессию для платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInitData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInitResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable
    @discardableResult
    @available(*, deprecated, message: "Use initPayment(data:completion:) instead")
    public func paymentInit(
        data: PaymentInitData,
        completionHandler: @escaping (_ result: Result<PaymentInitResponse, Error>) -> Void
    ) -> Cancellable {
        let paramsEnricher: IPaymentInitDataParamsEnricher = PaymentInitDataParamsEnricher()
        let enrichedData = paramsEnricher.enrich(data)
        let request = InitRequest(paymentInitData: enrichedData, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Finish Payment

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completion: результат операции `FinishAuthorizePayload` в случае удачного проведения платежа и `Error` - в случае ошибки.
    @discardableResult
    public func finishPayment(
        data: PaymentFinishRequestData,
        completion: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void
    ) -> Cancellable {
        let request = FinishAuthorizeRequest(
            paymentFinishRequestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )

        return api.performRequest(request, completion: completion)
    }

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `PaymentFinishResponse` в случае удачного проведения платежа и `Error` - в случае ошибки.
    @discardableResult
    @available(*, deprecated, message: "Use finishPayment(data:completion:) instead")
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
    ///   - completion: результат операции `Check3DSVersionPayload` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    public func check3DSVersion(
        data: Check3DSRequestData,
        completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void
    ) -> Cancellable {
        let request = Check3DSVersionRequest(
            check3DSRequestData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )
        
        return api.performRequest(request, completion: completion)
    }

    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `Check3dsVersionResponse` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    @available(*, deprecated, message: "Use check3DSVersion(data:completion:) instead")
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

    // TODO: Change response type
    // TODO: Add description
    @discardableResult
    public func submit3DSAuthorizationV2(
        cres: String,
        completion: @escaping (Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let cresData = CresData(cres: cres)
        let request = ThreeDSV2AuthorizationRequest(data: cresData, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    // MARK: Get Payment State

    /// Получить статус платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInfoData`
    ///   - completion: результат операции `GetPaymentStatePayload` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    public func getPaymentState(
        data: PaymentInfoData,
        completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetPaymentStateRequest(paymentInfoData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// Получить статус платежа
    @discardableResult
    @available(*, deprecated, message: "Use getPaymentState(data:completion:) instead")
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
    ///   - completion: результат операции `ChargePaymentPayload` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    public func charge(
        data: PaymentChargeRequestData,
        completion: @escaping (_ result: Result<ChargePaymentPayload, Error>) -> Void
    ) -> Cancellable {
        let request = ChargePaymentRequest(paymentChargeRequestData: data, baseURL: baseURL)
        return api.performRequest(request, completion: completion)
    }

    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    @discardableResult
    @available(*, deprecated, message: "Use charge(data:completion:) instead")
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
    ///   - completion: результат операции `[PaymentCard]` в случае успешного запроса и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func getCardList(
        data: GetCardListData,
        completion: @escaping (_ result: Result<[PaymentCard], Error>) -> Void
    ) -> Cancellable {
        let request = GetCardListRequest(getCardListData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - data: `InitGetCardListData` информация о клиенте для получения списка сохраненных карт
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use getCardList(data:completion:) instead")
    public func cardList(
        data: InitGetCardListData,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<CardListResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetCardListRequest(getCardListData: GetCardListData(customerKey: data.customerKey), baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    @discardableResult
    @available(*, deprecated, message: "Use getCardList(data:completion:) instead")
    public func сardList(
        data: InitGetCardListData,
        responseDelegate: NetworkTransportResponseDelegate?,
        completionHandler: @escaping (_ result: Result<CardListResponse, Error>) -> Void
    ) -> Cancellable {
        cardList(data: data, responseDelegate: responseDelegate, completion: completionHandler)
    }

    // MARK: Init Add Card

    /// Инициирует привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе привязки карты
    ///   - completion: результат операции `AddCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func initAddCard(
        data: InitAddCardData,
        completion: @escaping (_ result: Result<AddCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = AddCardRequest(initAddCardData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use initAddCard(data:completion:) instead")
    public func cardListAddCardInit(
        data: InitAddCardData,
        completion: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = AddCardRequest(initAddCardData: data, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    @discardableResult
    @available(*, deprecated, message: "Use initAddCard(data:completion:) instead")
    public func сardListAddCardInit(
        data: InitAddCardData,
        completionHandler: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListAddCardInit(data: data, completion: completionHandler)
    }

    // MARK: Finish Add Card

    /// Завершает привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `FinishAddCardData` информация о карте
    ///   - completion: результат операции `AttachCardPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func finishAddCard(
        data: FinishAddCardData,
        completion: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = AttachCardRequest(
            finishAddCardData: data,
            encryptor: RSAEncryptor(),
            cardDataFormatter: coreAssembly.cardDataFormatter(),
            publicKey: publicKey,
            baseURL: baseURL
        )

        return api.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use finishAddCard(data:completion:) instead")
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

    @discardableResult
    @available(*, deprecated, message: "Use finishAddCard(data:completion:) instead")
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

    // MARK: Submit Random Amount

    /// Подтверждения карты путем блокировки случайной суммы
    ///
    /// - Parameters:
    ///   - data: `SubmitRandomAmountData`
    ///   - completion: результат операции `SubmitRandomAmountPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func submitRandomAmount(
        data: SubmitRandomAmountData,
        completion: @escaping (_ result: Result<SubmitRandomAmountPayload, Error>) -> Void
    ) -> Cancellable {
        let request = SubmitRandomAmountRequest(submitRandomAmountData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - amount: `Double` сумма с копейками
    ///   - requestKey: `String` ключ для привязки карты
    ///   - completion: результат операции `AddCardStatusResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use submitRandomAmount(data:completion:) instead")
    public func checkRandomAmount(
        _ amount: Double,
        requestKey: String,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = SubmitRandomAmountRequest(submitRandomAmountData: .init(amount: Int64(amount), requestKey: requestKey), baseURL: baseURL)
        return api.performDeprecatedRequest(request, delegate: responseDelegate, completion: completion)
    }

    @discardableResult
    @available(*, deprecated, message: "Use submitRandomAmount(data:completion:) instead")
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
    ///     - completion: результат операции `RemoveCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`

    @discardableResult
    public func deactivateCard(
        data: InitDeactivateCardData,
        completion: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = RemoveCardRequest(deactivateCardData: data, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use deactivateCard(data:completion:) instead")
    public func cardListDeactivateCard(
        data: InitDeactivateCardData,
        completion: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = RemoveCardRequest(deactivateCardData: data, baseURL: baseURL)
        return api.performDeprecatedRequest(request, completion: completion)
    }

    @discardableResult
    @available(*, deprecated, message: "Use deactivateCard(data:completion:) instead")
    public func сardListDeactivateCard(
        data: InitDeactivateCardData,
        completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListDeactivateCard(data: data, completion: completionHandler)
    }
    
    // MARK: Get QR Code
    
    /// Сгенерировать QR-код для оплаты
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
    ///   - completion: результат операции `GetQrPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func getQRCode(
        data: PaymentInvoiceQRCodeData,
        completion: @escaping (_ result: Result<GetQrPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetQrRequest(data: data, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    /// Сгенерировать QR-код для оплаты
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use getQRCode(data:completion:) instead")
    public func paymentInvoiceQRCode(
        data: PaymentInvoiceQRCodeData,
        completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetQrRequest(data: data, baseURL: baseURL)
        return api.performDeprecatedRequest(request, completion: completionHandler)
    }

    // MARK: Get Static QR Code

    /// Выставить счет / принять оплату, сгенерировать QR-код для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceSBPSourceType` тип возвращаемых данных для генерации QR-кода
    ///   - completion: результат операции `GetStaticQrPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func getStaticQRCode(
        data: PaymentInvoiceSBPSourceType,
        completion: @escaping (_ result: Result<GetStaticQrPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetStaticQrRequest(sourceType: data, baseURL: baseURL)
        return api.performRequest(request, completion: completion)
    }

    /// Выставить счет / принять оплату, сгенерировать QR-код для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeResponseType` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use getStaticQRCode(data:completion:) instead")
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
    // TODO: Change requesting
    public func loadSBPBanks(completion: @escaping (Result<SBPBankResponse, Error>) -> Void) {
        let loader = DefaultSBPBankLoader()
        loader.loadBanks(completion: completion)
    }

    // MARK: Get TinkoffPay Status
    // TODO: (MIC-6303) Переписать метод под новый формат ответа

    @discardableResult
    public func getTinkoffPayStatus(
        completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = GetTinkoffPayStatusRequest(terminalKey: terminalKey, baseURL: baseURL)

        return api.performDeprecatedRequest(request, completion: completion)
    }

    // MARK: Get TinkoffPay Link
    // TODO: (MIC-6303) Переписать метод под новый формат ответа

    /// Получить ссылку для оплаты с помощью `TinkoffPay`
    ///
    /// - Parameters:
    ///   - paymentId: `PaymentId` - идентификтор платежа
    ///   - version: `GetTinkoffPayStatusPayload.Status.Version` - версия `TinkoffPay`
    ///   - completion: Callback с результатом запроса. `GetTinkoffLinkPayload` - при успехе, `Error` - при ошибке
    /// - Returns: `Cancellable`
    @discardableResult
    public func getTinkoffPayLink(
        paymentId: PaymentId,
        version: GetTinkoffPayStatusResponse.Status.Version,
        completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void
    ) -> Cancellable {
        let request = GetTinkoffLinkRequest(paymentId: paymentId, version: version, baseURL: baseURL)

        return api.performRequest(request, completion: completion)
    }

    // MARK: Get Certs Config
    // TODO: (MIC-6303) Переписать метод под новый формат ответа

    /// Получить конфигурацию для работы с сертификатами 3DS AppBased
    ///
    /// - Parameter completion: Callback с результатом запроса. `GetCertsConfigResponse` - при успехе, `Error` - при ошибке
    /// - Returns: Cancellable
    @discardableResult
    public func getCertsConfig(completion: @escaping (Result<GetCertsConfigResponse, Error>) -> Void) -> Cancellable {
        let request = GetCertsConfigRequest(baseURL: certsConfigUrl)
        return api.sendCertsConfigRequest(request, completionHandler: completion)
    }
}
