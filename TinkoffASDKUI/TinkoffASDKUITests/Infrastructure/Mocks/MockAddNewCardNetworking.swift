//
//  MockAddNewCardNetworking.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 28.12.2022.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MockAddNewCardNetworking: IAddNewCardNetworking {

    struct AddCardInputData {
        let number: String
        let expiration: String
        let cvc: String
        let resultCompletion: (Result<PaymentCard, Error>) -> Void
    }

    var addCardCallCounter = 0
    var addCardStub: (AddCardInputData) -> Void = { _ in }

    func addCard(
        number: String,
        expiration: String,
        cvc: String,
        resultCompletion: @escaping (Result<PaymentCard, Error>) -> Void
    ) {
        addCardCallCounter += 1
        addCardStub(
            AddCardInputData(
                number: number,
                expiration: expiration,
                cvc: cvc,
                resultCompletion: resultCompletion
            )
        )
    }
}
