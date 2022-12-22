//
//  IAddNewCardNetworking.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 21.12.2022.
//

import TinkoffASDKCore

protocol IAddNewCardNetworking {

    /// Метод добавления карты
    func addCard(
        number: String,
        expiration: String,
        cvc: String,
        resultCompletion: @escaping (Result<PaymentCard, Error>) -> Void
    )
}
