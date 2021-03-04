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

public enum AcquiringSdkError: Error {
    case publicKey(String)
}

///
/// `AcquiringSdk`  позволяет конфигурировать SDK и осуществлять взаимодействие с **Тинькофф Эквайринг API**  https://oplata.tinkoff.ru/landing/develop/
public final class AcquiringSdk: NSObject {
    private let publicKey: SecKey
    private let coreBuilder: CoreBuilder
    private let api: API
    
    public var fpsEnabled: Bool = false

    private var terminalKey: String
    private var terminalPassword: String
    public private(set) var languageKey: AcquiringSdkLanguage?
    private var logger: LoggerDelegate?

    /// Создает новый экземпляр SDK
    public init(configuration: AcquiringSdkConfiguration) throws {
        do {
            publicKey = try RSAEncryptor().createPublicSecKey(publicKey: configuration.credential.publicKey)
        } catch {
            throw AcquiringSdkError.publicKey(configuration.credential.publicKey)
        }
        
        coreBuilder = CoreBuilder(configuration: configuration)
        api = coreBuilder.buildAPI()
        
        fpsEnabled = configuration.fpsEnabled

        terminalKey = configuration.credential.terminalKey
        terminalPassword = configuration.credential.password
        
        languageKey = configuration.language
        logger = configuration.logger
    }

    /// Получить IP адресс
    public func networkIpAddress() -> IPAddress? {
        return coreBuilder.ipAddressProvider().ipAddress
    }

    // MARK: - Платежи

    /// Инициирует платежную сессию для платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInitPaymentData` информация о заказе на оплату
    ///   - completionHandler: результат операции `InitPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInit(data: PaymentInitData,
                            completionHandler: @escaping (_ result: Result<InitPayload, Error>) -> Void) -> Cancellable {
        let request = InitRequest(paymentInitData: data)
        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Подтверждает инициированный платеж передачей карточных данных
    ///
    /// - Parameters:
    ///   - data: `PaymentFinishRequestData`
    ///   - completionHandler: результат операции `FinishAuthorizePayload` в случае удачного проведеня платежа и `Error` - в случе ошибки.
    public func paymentFinish(data: PaymentFinishRequestData,
                              completionHandler: @escaping (_ result: Result<FinishAuthorizePayload, Error>) -> Void) -> Cancellable {

        let request = FinishAuthorizeRequest(paymentFinishRequestData: data,
                                             encryptor: RSAEncryptor(),
                                             cardDataFormatter: coreBuilder.cardDataFormatter(),
                                             publicKey: publicKey)

        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `Check3DSRequestData`
    ///   - completionHandler: результат операции `Check3DSVersionPayload` в случае удачного ответа и `Error` - в случе ошибки.
    public func check3dsVersion(data: Check3DSRequestData,
                                completionHandler: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void) -> Cancellable {
        let request = Check3DSVersionRequest(check3DSRequestData: data,
                                             encryptor: RSAEncryptor(),
                                             cardDataFormatter: coreBuilder.cardDataFormatter(),
                                             publicKey: publicKey)
        
        return api.performRequest(request, completion: completionHandler)
    }

    /// Получить статус платежа
    ///
    /// - Parameters:
    ///   - data: `PaymentInfoData`
    ///   - completionHandler: результат операции `GetPaymentStatePayload` в случае удачного ответа и `Error` - в случе ошибки.
    public func paymentOperationStatus(data: PaymentInfoData,
                                       completionHandler: @escaping (_ result: Result<GetPaymentStatePayload, Error>) -> Void) -> Cancellable {
        let request = GetPaymentStateRequest(paymentInfoData: data)
        
        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Подтверждает инициированный платеж передачей информации о рекуррентном платеже
    ///
    /// - Parameters:
    ///   - data: `PaymentChargeRequestData`
    ///   - completionHandler: результат операции `ChargePaymentPayload` в случае удачного ответа и `Error` - в случе ошибки.
    public func chargePayment(data: PaymentChargeRequestData,
                              completionHandler: @escaping (_ result: Result<ChargePaymentPayload, Error>) -> Void) -> Cancellable {
        let request = ChargePaymentRequest(paymentChargeRequestData: data)
        return api.performRequest(request, completion: completionHandler)
    }

    // MARK: - Работа с картами
    
    /// Получение всех сохраненных карт клиента
    ///
    /// - Parameters:
    ///   - data: `GetCardListData` информация о клиенте для получения списка сохраненных карт
    ///   - completionHandler: результат операции `[PaymentCard]` в случае успешного запроса и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func сardList(data: GetCardListData,
                          completionHandler: @escaping (_ result: Result<[PaymentCard], Error>) -> Void) -> Cancellable {
        let request = GetCardListRequest(getCardListData: data)
        return api.performRequest(request, completion: completionHandler)
    }
        
    /// Инициирует привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `InitAddCardData` информация о клиенте и типе привязки карты
    ///   - completionHandler: результат операции `AddCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func addCardInit(data: InitAddCardData,
                            completionHandler: @escaping (_ result: Result<AddCardPayload, Error>) -> Void) -> Cancellable {
        let request = AddCardRequest(initAddCardData: data)
        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Завершает привязку карты к клиенту
    ///
    /// - Parameters:
    ///   - data: `FinishAddCardData` информация о карте
    ///   - completionHandler: результат операции `AttachCardPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func addCardFinish(data: FinishAddCardData,
                              completionHandler: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void) -> Cancellable {
        let request = AttachCardRequest(finishAddCardData: data,
                                        encryptor: RSAEncryptor(),
                                        cardDataFormatter: coreBuilder.cardDataFormatter(),
                                        publicKey: publicKey)
        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Подтверждения карты путем блокировки случайной суммы
    ///
    /// - Parameters:
    ///   - data: `SubmitRandomAmountData`
    ///   - completionHandler: результат операции `SubmitRandomAmountPayload` в случае удачной регистрации карты и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func checkRandomAmount(data: SubmitRandomAmountData,
                                  completionHandler: @escaping (_ result: Result<SubmitRandomAmountPayload, Error>) -> Void) -> Cancellable {
        let request = SubmitRandomAmountRequest(submitRandomAmountData: data)
        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Удаление привязанной карты покупателя
    ///
    /// - Parameters:
    ///   - completionHandler: результат операции `RemoveCardPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func deactivateCard(data: InitDeactivateCardData,
                               completionHandler: @escaping (_ result: Result<RemoveCardPayload, Error>) -> Void) -> Cancellable {
        let request = RemoveCardRequest(deactivateCardData: data)
        return api.performRequest(request, completion: completionHandler)
    }
    
    // MARK: - СБП
    
    /// Сгенерировать QR-код для оплаты
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceQRCodeData` информация о заказе на оплату
    ///   - completionHandler: результат операции `GetQrPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInvoiceQRCode(data: PaymentInvoiceQRCodeData,
                                     completionHandler: @escaping (_ result: Result<GetQrPayload, Error>) -> Void) -> Cancellable {
        let request = GetQrRequest(data: data)
        return api.performRequest(request, completion: completionHandler)
    }
    
    /// Выставить счет / принять оплату, сгенерировать QR-код для принятия платежей
    ///
    /// - Parameters:
    ///   - data: `PaymentInvoiceSBPSourceType` тип возвращаемых данных для генерации QR-кода
    ///   - completionHandler: результат операции `GetStaticQrPayload` в случае удачной регистрации и  `Error` - ошибка.
    /// - Returns: `Cancellable`
    public func paymentInvoiceQRCodeCollector(data: PaymentInvoiceSBPSourceType, completionHandler: @escaping (_ result: Result<GetStaticQrPayload, Error>) -> Void) -> Cancellable {
        let request = GetStaticQrRequest(sourceType: data)
        return api.performRequest(request, completion: completionHandler)
    }

    // MARK: - подтверждение платежа

    /// Создать запрос для подтвержения платежа 3ds формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    public func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest {
        return try coreBuilder.threeDSURLRequestBuilder().buildConfirmation3DSRequest(requestData: data)
    }

    /// Создать запрос для подтвержения платежа 3ds формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    public func createConfirmation3DSRequestACS(data: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest {
        return try coreBuilder.threeDSURLRequestBuilder().buildConfirmation3DSRequestACS(requestData: data,
                                                                                         version: messageVersion)
    }
    
    /// Проверяет параметры для 3ds формы
    ///
    /// - Parameters:
    ///   - data: `Checking3DSURLData`
    /// - Returns:
    ///   - URLRequest
    public func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest {
        return try coreBuilder.threeDSURLRequestBuilder().build3DSCheckURLRequest(requestData: data)
    }

    /// callback URL для завершения 3ds подтверждения
    ///
    /// - Returns:
    ///   - URL
    public func confirmation3DSTerminationURL() throws -> URL {
        return try coreBuilder.threeDSURLBuilder().buildURL(type: .confirmation3DSTerminationURL)
    }

    public func confirmation3DSTerminationV2URL() throws -> URL {
        return try coreBuilder.threeDSURLBuilder().buildURL(type: .confirmation3DSTerminationV2URL)
    }
}
