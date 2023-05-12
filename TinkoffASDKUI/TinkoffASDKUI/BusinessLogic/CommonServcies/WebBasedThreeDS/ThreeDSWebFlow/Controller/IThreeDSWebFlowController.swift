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
    ///
    /// Используется в сценариях оплаты по карте и при привязке карты
    /// - Parameter checking3DSURLData: данные для выполнения сбора в скрытом webView
    func complete3DSMethod(checking3DSURLData: Checking3DSURLData) throws

    /// Выполняет подтверждение 3DS v1 , открывая экран с webView
    ///
    /// Используется в сценариях оплаты по карте, а так же при привязке карты, если необходимо сделать временное списание средств для проверки карты
    /// - Parameters:
    ///   - data: Данные для подтверждения 3DS v1
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`,
    ///   где в случае успеха вернется `GetPaymentStatePayload` - ответ сервера для API метода `Submit3DSAuthorization`
    func confirm3DS(
        data: Confirmation3DSData,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    )

    /// Выполняет подтверждение 3DS v2 , открывая экран с webView
    ///
    /// Используется в сценариях оплаты по карте, а так же при привязке карты, если необходимо сделать временное списание средств для проверки карты
    /// - Parameters:
    ///   - data: Данные для подтверждения 3DS v2
    ///   - completion: Замыкание, вызываемое на главном потоке после выполнения подтверждения.
    ///   Возвращает `ThreeDSWebViewHandlingResult`,
    ///   где в случае успеха вернется `GetPaymentStatePayload` - ответ сервера для API метода `Submit3DSAuthorizationV2`
    func confirm3DSACS(
        data: Confirmation3DSDataACS,
        messageVersion: String,
        completion: @escaping (ThreeDSWebViewHandlingResult<GetPaymentStatePayload>) -> Void
    )
}
