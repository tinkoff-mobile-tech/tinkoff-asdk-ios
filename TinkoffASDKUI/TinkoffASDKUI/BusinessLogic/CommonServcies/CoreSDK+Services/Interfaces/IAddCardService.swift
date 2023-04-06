//
//  IAddCardService.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.03.2023.
//

import TinkoffASDKCore

protocol IAddCardService {

    /// Инициирует привязку карты к клиенту
    @discardableResult
    func addCard(
        data: AddCardData,
        completion: @escaping (_ result: Result<AddCardPayload, Error>) -> Void
    ) -> Cancellable

    /// Проверяем версию проверки 3DS
    @discardableResult
    func check3DSVersion(
        data: Check3DSVersionData,
        completion: @escaping (_ result: Result<Check3DSVersionPayload, Error>) -> Void
    ) -> Cancellable

    /// Завершает привязку карты к клиенту
    @discardableResult
    func attachCard(
        data: AttachCardData,
        completion: @escaping (_ result: Result<AttachCardPayload, Error>) -> Void
    ) -> Cancellable

    ///  Возвращает статус привязки карты
    @discardableResult
    func getAddCardState(
        data: GetAddCardStateData,
        completion: @escaping (Result<GetAddCardStatePayload, Error>) -> Void
    ) -> Cancellable
}
