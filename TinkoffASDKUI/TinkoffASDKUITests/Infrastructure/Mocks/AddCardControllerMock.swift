//
//  AddCardControllerMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 30.03.2023.
//

import TinkoffASDKCore
import TinkoffASDKUI

final class AddCardControllerMock: IAddCardController {

    var webFlowDelegate: (any ThreeDSWebFlowDelegate)? {
        get { underlyingWebFlowDelegate }
        set { underlyingWebFlowDelegate = newValue }
    }

    var underlyingWebFlowDelegate: (any ThreeDSWebFlowDelegate)?

    var customerKey: String {
        get { underlyingCustomerKey }
        set { underlyingCustomerKey = newValue }
    }

    var underlyingCustomerKey: String!

    // MARK: - addCard

    typealias AddCardArguments = (options: CardOptions, completion: (AddCardStateResult) -> Void)

    var addCardCallsCount = 0
    var addCardCompletionStub: AddCardStateResult?
    var addCardReceivedArguments: AddCardArguments?
    var addCardReceivedInvocations: [AddCardArguments] = []

    func addCard(options: CardOptions, completion: @escaping (AddCardStateResult) -> Void) {
        addCardCallsCount += 1
        let arguments = (options, completion)
        addCardReceivedArguments = arguments
        addCardReceivedInvocations.append(arguments)
        if let addCardCompletionStub = addCardCompletionStub {
            completion(addCardCompletionStub)
        }
    }
}
