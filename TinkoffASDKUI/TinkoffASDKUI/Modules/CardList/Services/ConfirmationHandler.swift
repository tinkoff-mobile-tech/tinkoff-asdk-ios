//
//  ConfirmationHandler.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.09.2022.
//

import TinkoffASDKCore

public protocol ConfirmationHandler {

    /// Обработка потверждения карты
    /// после обработки нужно вызвать resultHandler и передать ему cardId: String или же ошибку
    func handleAddCardConfirmation(
        response: AttachCardPayload,
        resultHandler: @escaping (Result<String, Error>) -> Void
    )
}
