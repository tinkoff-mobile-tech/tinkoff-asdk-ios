//
//  AddCardControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 30.03.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI

final class AddCardControllerMock: IAddCardController {
    var webFlowDelegate: (any ThreeDSWebFlowDelegate)?

    var customerKey: String {
        get { return underlyingCustomerKey }
        set(value) { underlyingCustomerKey = value }
    }

    var underlyingCustomerKey: String!

    // MARK: - addCard

    typealias AddCardArguments = (cardData: CardData, completion: (AddCardStateResult) -> Void)

    var addCardCallsCount = 0
    var addCardReceivedArguments: AddCardArguments?
    var addCardReceivedInvocations: [AddCardArguments?] = []
    var addCardCompletionClosureInput: AddCardStateResult?

    func addCard(cardData: CardData, completion: @escaping (AddCardStateResult) -> Void) {
        addCardCallsCount += 1
        let arguments = (cardData, completion)
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        if let addCardCompletionClosureInput = addCardCompletionClosureInput {
            completion(addCardCompletionClosureInput)
        }
    }
}

// MARK: - Resets

extension AddCardControllerMock {
    func fullReset() {
        addCardCallsCount = 0
        addCardReceivedArguments = nil
        addCardReceivedInvocations = []
        addCardCompletionClosureInput = nil
    }
}
