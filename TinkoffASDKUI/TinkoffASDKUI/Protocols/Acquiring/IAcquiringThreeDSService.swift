//
//  ThreeDSProtocols.swift
//  Pods
//
//  Created by Ivan Glushko on 19.10.2022.
//

import Foundation
import TinkoffASDKCore

protocol IAcquiringThreeDSService {

    // MARK: Check 3DS Version

    /// Проверяем версию 3DS перед подтверждением инициированного платежа передачей карточных данных и идентификатора платежа
    ///
    /// - Parameters:
    ///   - data: `Check3DSVersionData`
    ///   - completion: результат операции `Check3DSVersionPayload` в случае удачного ответа и `Error` - в случае ошибки.
    @discardableResult
    func check3DSVersion(
        data: Check3DSVersionData,
        completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void
    ) -> Cancellable

    // MARK: 3DS URL Building

    /// callback URL для завершения 3DS подтверждения
    ///
    /// - Returns:
    ///   - URL
    func confirmation3DSTerminationURL() -> URL
    func confirmation3DSTerminationV2URL() -> URL
    func confirmation3DSCompleteV2URL() -> URL

    /// Проверяет параметры для 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Checking3DSURLData`
    /// - Returns:
    ///   - URLRequest
    func createChecking3DSURL(data: Checking3DSURLData) throws -> URLRequest

    // MARK: 3DS Request building

    /// Создать запрос для подтверждения платежа 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    func createConfirmation3DSRequest(data: Confirmation3DSData) throws -> URLRequest

    /// Создать запрос для подтверждения платежа 3DS формы
    ///
    /// - Parameters:
    ///   - data: `Confirmation3DSData`
    /// - Returns:
    ///   - URLRequest
    func createConfirmation3DSRequestACS(data: Confirmation3DSDataACS, messageVersion: String) throws -> URLRequest
}
