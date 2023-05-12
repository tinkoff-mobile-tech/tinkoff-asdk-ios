//
//  CardsControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by r.akhmadeev on 22.02.2023.
//

import Foundation
import TinkoffASDKCore
import TinkoffASDKUI

final class CardsControllerMock: ICardsController {
    var webFlowDelegate: TinkoffASDKUI.ThreeDSWebFlowDelegate?
    var customerKey: String = "test"

    var addCardCallsCount = 0
    var addCardStub: (_ options: CardOptions, _ completion: (AddCardResult) -> Void) -> Void = { _, completion in
        completion(.succeded(PaymentCard(pan: "", cardId: "", status: .active, parentPaymentId: nil, expDate: "")))
    }

    func addCard(options: CardOptions, completion: @escaping (AddCardResult) -> Void) {
        addCardCallsCount += 1
        addCardStub(options, completion)
    }

    var removeCardCallsCount = 0
    var removeCardStub: (_ cardId: String, _ completion: (Result<RemoveCardPayload, Error>) -> Void) -> Void = { _, completion in
        completion(.success(RemoveCardPayload(cardId: "", cardStatus: .deleted)))
    }

    func removeCard(cardId: String, completion: @escaping (Result<RemoveCardPayload, Error>) -> Void) {
        removeCardCallsCount += 1
        removeCardStub(cardId, completion)
    }

    var getActiveCardsCallsCount = 0
    var getActiveCardsStub: (_ completion: (Result<[PaymentCard], Error>) -> Void) -> Void = { completion in
        completion(.success([]))
    }

    func getActiveCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        getActiveCardsCallsCount += 1
        getActiveCardsStub(completion)
    }
}
