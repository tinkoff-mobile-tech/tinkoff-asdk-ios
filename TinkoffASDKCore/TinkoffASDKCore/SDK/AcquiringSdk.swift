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

import struct CoreGraphics.CGSize
import Foundation
import UIKit

/// `AcquiringSdk`  позволяет конфигурировать SDK и осуществлять взаимодействие с **Тинькофф Эквайринг API**  https://oplata.tinkoff.ru/landing/develop/
public final class AcquiringSdk: NSObject {
    @available(*, deprecated, message: "Property does not affect anything")
    public var fpsEnabled = false

    /// Текущий IP адрес
    public var ipAddress: IPAddress? {
        ipAddressProvider.ipAddress
    }

    public var languageKey: AcquiringSdkLanguage? {
        languageProvider.language
    }

    // MARK: Dependencies

    public let ipAddressProvider: IIPAddressProvider

    private let acquiringAPI: IAcquiringAPIClient
    private let acquiringRequests: IAcquiringRequestBuilder
    private let externalAPI: IExternalAPIClient
    private let externalRequests: IExternalRequestBuilder
    private let threeDSFacade: IThreeDSFacade
    private let languageProvider: ILanguageProvider

    // MARK: Init

    init(
        acquiringAPI: IAcquiringAPIClient,
        acquiringRequests: IAcquiringRequestBuilder,
        externalAPI: IExternalAPIClient,
        externalRequests: IExternalRequestBuilder,
        ipAddressProvider: IIPAddressProvider,
        threeDSFacade: IThreeDSFacade,
        languageProvider: ILanguageProvider
    ) {
        self.acquiringAPI = acquiringAPI
        self.acquiringRequests = acquiringRequests
        self.externalAPI = externalAPI
        self.externalRequests = externalRequests
        self.ipAddressProvider = ipAddressProvider
        self.threeDSFacade = threeDSFacade
        self.languageProvider = languageProvider
    }

    /// Получить IP адрес
    @available(*, deprecated, message: "Use `ipAddress` instead")
    public func networkIpAddress() -> String? {
        ipAddressProvider.ipAddress?.stringValue
    }

    // MARK: 3DS Request building

    /// Создать запрос для подтверждения платежа 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    public func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
        try threeDSFacade.buildConfirmation3DSRequest(requestData: data)
    }

    /// Создать запрос для подтверждения платежа 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    public func createConfirmation3DSRequestACS(data: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest {
        try threeDSFacade.buildConfirmation3DSRequestACS(requestData: data, version: messageVersion)
    }

    /// Проверяет параметры для 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Checking3DSURLData`
    /// - Returns:
    ///   - URLRequest
    public func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
        try threeDSFacade.build3DSCheckURLRequest(requestData: data)
    }

    // MARK: 3DS URL Building

    /// callback URL для завершения 3DS подтверждения
    ///
    /// - Returns:
    ///   - URL
    public func confirmation3DSTerminationURL() -> URL {
        threeDSFacade.url(ofType: .confirmation3DSTerminationURL)
    }

    public func confirmation3DSTerminationV2URL() -> URL {
        threeDSFacade.url(ofType: .confirmation3DSTerminationV2URL)
    }

    public func confirmation3DSCompleteV2URL() -> URL {
        threeDSFacade.url(ofType: .threeDSCheckNotificationURL)
    }

    // MARK: 3DS Handling

    public func payment3DSHandler() -> ThreeDSWebViewHandler<GetPaymentStatePayload> {
        threeDSFacade.threeDSWebViewHandler()
    }

    public func addCard3DSHandler() -> ThreeDSWebViewHandler<AttachCardPayload> {
        threeDSFacade.threeDSWebViewHandler()
    }

    public func threeDSDeviceInfoProvider() -> IThreeDSDeviceInfoProvider {
        threeDSFacade.threeDSDeviceInfoProvider()
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
        let request = acquiringRequests.initRequest(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Инициирует платежную сессию для платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInitData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInitResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable
    @discardableResult
    @available(*, deprecated, message: "Use `initPayment(data:completion:)` instead")
    public func paymentInit(
        data: PaymentInitData,
        completionHandler: @escaping (_ result: Result<PaymentInitResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.initRequest(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
    }

    // MARK: Finish Authorize

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `FinishAuthorizeData`
    ///   - completion: результат операции `FinishAuthorizePayload` в случае удачного проведения платежа и `Error` - в случае ошибки.
    @discardableResult
    public func finishAuthorize(
        data: FinishAuthorizeData,
        completion: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.finishAuthorize(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `PaymentFinishResponse` в случае удачного проведения платежа и `Error` - в случае ошибки.
    @discardableResult
    @available(*, deprecated, message: "Use `finishAuthorize(data:completion:)` instead")
    public func paymentFinish(
        data: PaymentFinishRequestData,
        completionHandler: @escaping (_ result: Result<PaymentFinishResponse, Error>) -> Void
    ) -> Cancellable {
        let finishData = FinishAuthorizeData(
            paymentId: String(data.paymentId),
            paymentSource: data.paymentSource,
            infoEmail: data.infoEmail,
            deviceInfo: data.deviceInfo,
            threeDSVersion: data.threeDSVersion,
            source: data.source,
            route: data.route
        )
        let request = acquiringRequests.finishAuthorize(data: finishData)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
    }

    // MARK: Check 3DS Version

    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `Check3DSVersionData`
    ///   - completion: результат операции `Check3DSVersionPayload` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    public func check3DSVersion(
        data: Check3DSVersionData,
        completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.check3DSVersion(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `Check3dsVersionResponse` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    @available(*, deprecated, message: "Use `check3DSVersion(data:completion:)` instead")
    public func check3dsVersion(
        data: PaymentFinishRequestData,
        completionHandler: @escaping (_ result: Result<Check3dsVersionResponse, Error>) -> Void
    ) -> Cancellable {
        let check3DSData = Check3DSVersionData(paymentId: String(data.paymentId), paymentSource: data.paymentSource)
        let request = acquiringRequests.check3DSVersion(data: check3DSData)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
    }

    // MARK: Submit 3DS Authorization V2

    // TODO: MIC-6303 Переписать метод под новый формат ответа

    @discardableResult
    public func submit3DSAuthorizationV2(
        cres: String,
        completion: @escaping (Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.submit3DSAuthorizationV2(data: CresData(cres: cres))
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completion)
    }

    // MARK: Get Payment State

    /// Получить статус платежа
    ///
    /// - Parameters:
    ///   - data: `GetPaymentStateData`
    ///   - completion: результат операции `GetPaymentStatePayload` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    public func getPaymentState(
        data: GetPaymentStateData,
        completion: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getPaymentState(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Получить статус платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInfoData`
    ///   - completion: результат операции `PaymentStatusResponse` в случае удачного ответа и `Error` - в случае ошибки.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `getPaymentState(data:completion:)` instead")
    public func paymentOperationStatus(
        data: GetPaymentStateData,
        completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getPaymentState(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
    }

    // MARK: Charge Payment

    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    ///
    /// - Parameters:
    ///   - data: `ChargeData`
    ///   - completion: результат операции `ChargePayload` в случае удачного ответа и `Error` - в случае ошибки.
    /// - Returns: `Cancellable`
    @discardableResult
    public func charge(
        data: ChargeData,
        completion: @escaping (_ result: Result<ChargePayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.charge(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    ///
    /// - Parameters:
    ///   - data: `PaymentChargeRequestData`
    ///   - completion: результат операции `PaymentStatusResponse` в случае удачного ответа и `Error` - в случае ошибки.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `charge(data:completion:)` instead")
    public func chargePayment(
        data: PaymentChargeRequestData,
        completionHandler: @escaping (_ result: Result<PaymentStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let chargeData = ChargeData(paymentId: String(data.paymentId), rebillId: String(data.parentPaymentId))
        let request = acquiringRequests.charge(data: chargeData)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
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
        let request = acquiringRequests.getCardList(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - data: `InitGetCardListData` информация о клиенте для получения списка сохраненных карт
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `getCardList(data:completion:)` instead")
    public func cardList(
        data: InitGetCardListData,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<CardListResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getCardList(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: responseDelegate, completion: completion)
    }

    @discardableResult
    @available(*, deprecated, message: "Use `getCardList(data:completion:)` instead")
    public func сardList(
        data: InitGetCardListData,
        responseDelegate: NetworkTransportResponseDelegate?,
        completionHandler: @escaping (_ result: Result<CardListResponse, Error>) -> Void
    ) -> Cancellable {
        cardList(data: data, responseDelegate: responseDelegate, completion: completionHandler)
    }

    // MARK: Add Card

    /// Инициирует привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `AddCardData` информация о клиенте и типе привязки карты
    ///   - completion: результат операции `AddCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func addCard(
        data: AddCardData,
        completion: @escaping (_ result: Result<AddCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.addCard(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// - Parameters:
    ///   - data: `AddCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `CardListResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `addCard(data:completion:)` instead")
    public func cardListAddCardInit(
        data: AddCardData,
        completion: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.addCard(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completion)
    }

    @discardableResult
    @available(*, deprecated, message: "Use `addCard(data:completion:)` instead")
    public func сardListAddCardInit(
        data: AddCardData,
        completionHandler: @escaping (_ result: Result<InitAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListAddCardInit(data: data, completion: completionHandler)
    }

    // MARK: Attach Card

    /// Завершает привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `AttachCardData` информация о карте
    ///   - completion: результат операции `AttachCardPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func attachCard(
        data: AttachCardData,
        completion: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.attachCard(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Завершает привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `AttachCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `FinishAddCardResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `finishAddCard(data:completion:)` instead")
    public func cardListAddCardFinish(
        data: AttachCardData,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.attachCard(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: responseDelegate, completion: completion)
    }

    /// Завершает привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `AttachCardData` информация о клиенте и типе новой карты
    ///   - completion: результат операции `FinishAddCardResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `finishAddCard(data:completion:)` instead")
    public func сardListAddCardFinish(
        data: AttachCardData,
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

    /// Подтверждение карты путем блокировки случайной суммы
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
        let request = acquiringRequests.submitRandomAmount(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Подтверждение карты путем блокировки случайной суммы
    ///
    /// - Parameters:
    ///   - amount: `Double` сумма с копейками
    ///   - requestKey: `String` ключ для привязки карты
    ///   - completion: результат операции `AddCardStatusResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `submitRandomAmount(data:completion:)` instead")
    public func checkRandomAmount(
        _ amount: Double,
        requestKey: String,
        responseDelegate: NetworkTransportResponseDelegate? = nil,
        completion: @escaping (_ result: Result<AddCardStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.submitRandomAmount(data: SubmitRandomAmountData(amount: Int64(amount * 100), requestKey: requestKey))
        return acquiringAPI.performDeprecatedRequest(request, delegate: responseDelegate, completion: completion)
    }

    /// Подтверждение карты путем блокировки случайной суммы
    ///
    /// - Parameters:
    ///   - amount: `Double` сумма с копейками
    ///   - requestKey: `String` ключ для привязки карты
    ///   - completion: результат операции `AddCardStatusResponse` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `submitRandomAmount(data:completion:)` instead")
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

    // MARK: Remove Card

    /// Удаление привязанной карты покупателя
    ///
    /// - Parameters:
    ///   - data: `RemoveCardData`
    ///   - completion: результат операции `RemoveCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func removeCard(
        data: RemoveCardData,
        completion: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.removeCard(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Удаление привязанной карты покупателя
    ///
    /// - Parameters:
    ///   - data: `RemoveCardData`
    ///   - completion: результат операции `FinishAddCardResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `removeCard(data:completion:)` instead")
    public func cardListDeactivateCard(
        data: RemoveCardData,
        completion: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.removeCard(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completion)
    }

    /// Удаление привязанной карты покупателя
    ///
    /// - Parameters:
    ///   - completion: результат операции `FinishAddCardResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `removeCard(data:completion:)` instead")
    public func сardListDeactivateCard(
        data: RemoveCardData,
        completionHandler: @escaping (_ result: Result<FinishAddCardResponse, Error>) -> Void
    ) -> Cancellable {
        cardListDeactivateCard(data: data, completion: completionHandler)
    }

    // MARK: Get QR

    /// Сгенерировать QR для оплаты
    ///
    /// - Parameters:
    ///   - data: `GetQRData` информация о заказе на оплату
    ///   - completion: результат операции `GetQRPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func getQR(
        data: GetQRData,
        completion: @escaping (_ result: Result<GetQRPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getQR(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Сгенерировать QR для оплаты
    ///
    /// - Parameters:
    ///   - data: `GetQRData` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `getQR(data:completion:)` instead")
    public func paymentInvoiceQRCode(
        data: GetQRData,
        completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getQR(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
    }

    // MARK: Get Static QR

    /// Выставить счет / принять оплату, сгенерировать QR для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `GetQRDataType` тип возвращаемых данных для генерации QR-кода
    ///   - completion: результат операции `GetStaticQRPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    public func getStaticQR(
        data: GetQRDataType,
        completion: @escaping (_ result: Result<GetStaticQRPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getStaticQR(data: data)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    /// Выставить счет / принять оплату, сгенерировать QR для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `GetQRDataType` информация о заказе на оплату
    ///   - completionHandler: результат операции `PaymentInvoiceQRCodeResponse` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `getStaticQR(data:completion:)` instead")
    public func paymentInvoiceQRCodeCollector(
        data: GetQRDataType,
        completionHandler: @escaping (_ result: Result<PaymentInvoiceQRCodeCollectorResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getStaticQR(data: data)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completionHandler)
    }

    // MARK: Load SBP Banks

    // TODO: MIC-6303 Переписать метод под новый формат ответа

    /// Загрузить список банков, через приложения которых можно совершить оплату СБП
    ///
    /// - Parameters:
    ///   - completion: результат запроса. `SBPBankResponse` в случае успешного запроса и  `Error` - ошибка.
    public func loadSBPBanks(completion: @escaping (Result<SBPBankResponse, Error>) -> Void) {
        let loader = DefaultSBPBankLoader()
        loader.loadBanks(completion: completion)
    }

    // MARK: Get TinkoffPay Status

    // TODO: MIC-6303 Переписать метод под новый формат ответа

    @discardableResult
    public func getTinkoffPayStatus(
        completion: @escaping (Result<GetTinkoffPayStatusResponse, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getTinkoffPayStatus()
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completion)
    }

    // MARK: Get TinkoffPay Link

    // TODO: MIC-6303 Переписать метод под новый формат ответа

    /// Получить ссылку для оплаты с помощью `TinkoffPay`
    ///
    /// - Parameters:
    ///   - paymentId: `String` - идентификтор платежа
    ///   - version: `GetTinkoffPayStatusPayload.Status.Version` - версия `TinkoffPay`
    ///   - completion: Callback с результатом запроса. `GetTinkoffLinkPayload` - при успехе, `Error` - при ошибке
    /// - Returns: `Cancellable`
    @discardableResult
    public func getTinkoffPayLink(
        paymentId: String,
        version: GetTinkoffPayStatusResponse.Status.Version,
        completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getTinkoffPayLink(paymentId: paymentId, version: version)
        return acquiringAPI.performDeprecatedRequest(request, delegate: nil, completion: completion)
    }

    /// Получить ссылку для оплаты с помощью `TinkoffPay`
    ///
    /// - Parameters:
    ///   - paymentId: `Int64` - идентификтор платежа
    ///   - version: `GetTinkoffPayStatusPayload.Status.Version` - версия `TinkoffPay`
    ///   - completion: Callback с результатом запроса. `GetTinkoffLinkPayload` - при успехе, `Error` - при ошибке
    /// - Returns: `Cancellable`
    @discardableResult
    @available(*, deprecated, message: "Use `getTinkoffPayLink(paymentId:version:completion:)` with String `paymentId` instead")
    public func getTinkoffPayLink(
        paymentId: Int64,
        version: GetTinkoffPayStatusResponse.Status.Version,
        completion: @escaping (Result<GetTinkoffLinkPayload, Error>) -> Void
    ) -> Cancellable {
        let request = acquiringRequests.getTinkoffPayLink(paymentId: String(paymentId), version: version)
        return acquiringAPI.performRequest(request, completion: completion)
    }

    // MARK: Get Terminal Pay Methods

    /// Получить информацию о доступных методах оплаты и настройках терминала
    ///
    /// - Parameter completion: Callback с результатом запроса. `GetTerminalPayMethodsPayload` - при успехе, `Error` - при ошибке
    /// - Returns: `Cancellable`
    @discardableResult
    public func getTerminalPayMethods(completion: @escaping (Result<GetTerminalPayMethodsPayload, Error>) -> Void) -> Cancellable {
        let request = acquiringRequests.getTerminalPayMethods()
        return acquiringAPI.performRequest(request, completion: completion)
    }

    // MARK: Get Certs Config

    /// Получить конфигурацию для работы с сертификатами 3DS AppBased
    ///
    /// - Parameter completion: Callback с результатом запроса. `Get3DSAppBasedCertsConfigPayload` - при успехе, `Error` - при ошибке
    /// - Returns: Cancellable
    @discardableResult
    public func getCertsConfig(completion: @escaping (Result<Get3DSAppBasedCertsConfigPayload, Error>) -> Void) -> Cancellable {
        let request = externalRequests.get3DSAppBasedConfigRequest()
        return externalAPI.perform(request, completion: completion)
    }
}
