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
    var webFlowDelegate: (any ThreeDSWebFlowDelegate)?

    var customerKey: String {
        get { return underlyingCustomerKey }
        set(value) { underlyingCustomerKey = value }
    }

    var underlyingCustomerKey = "test"

    // MARK: - addCard

    typealias AddCardArguments = (cardData: CardData, completion: (AddCardResult) -> Void)

    var addCardCallsCount = 0
    var addCardReceivedArguments: AddCardArguments?
    var addCardReceivedInvocations: [AddCardArguments?] = []
    var addCardCompletionClosureInput: AddCardResult?

    func addCard(cardData: CardData, completion: @escaping (AddCardResult) -> Void) {
        addCardCallsCount += 1
        let arguments = (cardData, completion)
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        if let addCardCompletionClosureInput = addCardCompletionClosureInput {
            completion(addCardCompletionClosureInput)
        }
    }

    // MARK: - removeCard

    typealias RemoveCardArguments = (cardId: String, completion: (Result<RemoveCardPayload, Error>) -> Void)

    var removeCardCallsCount = 0
    var removeCardReceivedArguments: RemoveCardArguments?
    var removeCardReceivedInvocations: [RemoveCardArguments?] = []
    var removeCardCompletionClosure: (() -> Void)?
    var removeCardCompletionClosureInput: Result<RemoveCardPayload, Error>?

    func removeCard(cardId: String, completion: @escaping (Result<RemoveCardPayload, Error>) -> Void) {
        removeCardCallsCount += 1
        let arguments = (cardId, completion)
        removeCardReceivedArguments = arguments
        removeCardReceivedInvocations.append(arguments)
        if let removeCardCompletionClosure = removeCardCompletionClosure,
           let removeCardCompletionClosureInput = removeCardCompletionClosureInput {
            completion(removeCardCompletionClosureInput)
            removeCardCompletionClosure()
        } else if let removeCardCompletionClosureInput = removeCardCompletionClosureInput {
            completion(removeCardCompletionClosureInput)
        }
    }

    // MARK: - getActiveCards

    typealias GetActiveCardsArguments = (Result<[PaymentCard], Error>) -> Void

    var getActiveCardsCallsCount = 0
    var getActiveCardsReceivedArguments: GetActiveCardsArguments?
    var getActiveCardsReceivedInvocations: [GetActiveCardsArguments?] = []
    var getActiveCardsCompletionClosureInput: Result<[PaymentCard], Error>?

    func getActiveCards(completion: @escaping (Result<[PaymentCard], Error>) -> Void) {
        getActiveCardsCallsCount += 1
        let arguments = completion
        getActiveCardsReceivedArguments = arguments
        getActiveCardsReceivedInvocations.append(arguments)
        if let getActiveCardsCompletionClosureInput = getActiveCardsCompletionClosureInput {
            completion(getActiveCardsCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension CardsControllerMock {
    func fullReset() {
        addCardCallsCount = 0
        addCardReceivedArguments = nil
        addCardReceivedInvocations = []
        addCardCompletionClosureInput = nil

        removeCardCallsCount = 0
        removeCardReceivedArguments = nil
        removeCardReceivedInvocations = []
        removeCardCompletionClosureInput = nil

        getActiveCardsCallsCount = 0
        getActiveCardsReceivedArguments = nil
        getActiveCardsReceivedInvocations = []
        getActiveCardsCompletionClosureInput = nil
    }
}
