//
//  IThreeDSWebFlowController.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 17.02.2023.
//

import Foundation
import TinkoffASDKCore

/// Объект, взаимодействующий с webView для подтверждения 3DS
protocol IThreeDSWebFlowController: AnyObject {
    /// Объект, предоставляющий UI-компоненты для прохождения 3DS Web Based Flow
    var webFlowDelegate: ThreeDSWebFlowDelegate? { get set }

    /// Собирает данные об устройстве в скрытом webView после проверки версии 3DS
    /// - Parameter checking3DSURLData: данные для выполнения сбора в скрытом webView
    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws

    /// Выполняет подтверждение 3DS v1 , открывая экран с webView
    /// - Parameters:
    ///   - data: Данные для подтверждения 3DS v1
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`, где в случае успеха вернется абстрактный `Decodable-ответ` сервера для API метода `Submit3DSAuthorization`
    func confirm3DS<Payload: Decodable>(
        data: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    )

    /// Выполняет подтверждение 3DS v2, открывая экран с webView
    /// - Parameters:
    ///   - data: Данные для подтверждения 3DS v2
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает ThreeDSWebViewHandlingResult, где в случае успеха вернется абстрактный `Decodable-ответ` сервера для API метода `Submit3DSAuthorizationV2`
    func confirm3DSACS<Payload: Decodable>(
        data: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<Payload>) -> Void
    )
}

// MARK: - IThreeDSWebFlowController + Payment Flow

extension IThreeDSWebFlowController {
    /// Выполняет подтверждение 3DS v1 , открывая экран с webView
    /// - Parameters:
    ///   - paymentConfirmationData: Данные для подтверждения 3DS v1
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`,
    ///   где в случае успеха вернется `GetPaymentStatePayload` - ответ сервера для API метода `Submit3DSAuthorization` при оплате
    func confirm3DS(
        paymentConfirmationData: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    ) {
        confirm3DS(data: paymentConfirmationData, completion: completion)
    }

    /// Выполняет подтверждение 3DS v2 , открывая экран с webView
    /// - Parameters:
    ///   - paymentConfirmationData: Данные для подтверждения 3DS v2
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`,
    ///   где в случае успеха вернется `GetPaymentStatePayload` - ответ сервера для API метода `Submit3DSAuthorizationV2` при оплате
    func confirm3DSACS(
        paymentConfirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    ) {
        confirm3DSACS(data: paymentConfirmationData, messageVersion: messageVersion, completion: completion)
    }
}

// MARK: - IThreeDSWebFlowController + Add Card Flow

extension IThreeDSWebFlowController {
    /// Выполняет подтверждение 3DS v1 , открывая экран с webView
    /// - Parameters:
    ///   - addCardConfirmationData: Данные для подтверждения 3DS v1
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`,
    ///   где в случае успеха вернется `GetAddCardStatePayload` - ответ сервера для API метода `Submit3DSAuthorization` при привязке карты
    func confirm3DS(
        addCardConfirmationData: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetAddCardStatePayload>) -> Void
    ) {
        confirm3DS(data: addCardConfirmationData, completion: completion)
    }

    /// Выполняет подтверждение 3DS v2 , открывая экран с webView
    /// - Parameters:
    ///   - addCardConfirmationData: Данные для подтверждения 3DS v2
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`,
    ///   где в случае успеха вернется `GetAddCardStatePayload` - ответ сервера для API метода `Submit3DSAuthorizationV2` при привязке карты
    func confirm3DSACS(
        addCardConfirmationData: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetAddCardStatePayload>) -> Void
    ) {
        confirm3DSACS(data: addCardConfirmationData, messageVersion: messageVersion, completion: completion)
    }
}
