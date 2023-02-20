//
//  IAddNewCardNetworking.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 21.12.2022.
//

import TinkoffASDKCore

protocol IAddNewCardNetworking {

    /// Метод добавления карты
    /// Должен вернуть resultCompletion на main потоке!
    func addCard(
        number: String,
        expiration: String,
        cvc: String,
        resultCompletion: @escaping (AddCardResult) -> Void
    )
}
