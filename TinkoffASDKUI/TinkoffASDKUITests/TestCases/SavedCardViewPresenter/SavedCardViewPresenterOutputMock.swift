//
//  SavedCardViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SavedCardViewPresenterOutputMock: ISavedCardViewPresenterOutput {

    // MARK: - savedCardPresenterPresenterPaymentCard

    typealias SavedCardPresenterPresenterPaymentCardArguments = (presenter: SavedCardViewPresenter, paymentCard: PaymentCard)

    var savedCardPresenterPresenterPaymentCardCallsCount = 0
    var savedCardPresenterPresenterPaymentCardReceivedArguments: SavedCardPresenterPresenterPaymentCardArguments?
    var savedCardPresenterPresenterPaymentCardReceivedInvocations: [SavedCardPresenterPresenterPaymentCardArguments?] = []

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didRequestReplacementFor paymentCard: PaymentCard) {
        savedCardPresenterPresenterPaymentCardCallsCount += 1
        let arguments = (presenter, paymentCard)
        savedCardPresenterPresenterPaymentCardReceivedArguments = arguments
        savedCardPresenterPresenterPaymentCardReceivedInvocations.append(arguments)
    }

    // MARK: - savedCardPresenterPresenterCvc

    typealias SavedCardPresenterPresenterCvcArguments = (presenter: SavedCardViewPresenter, cvc: String, isValid: Bool)

    var savedCardPresenterPresenterCvcCallsCount = 0
    var savedCardPresenterPresenterCvcReceivedArguments: SavedCardPresenterPresenterCvcArguments?
    var savedCardPresenterPresenterCvcReceivedInvocations: [SavedCardPresenterPresenterCvcArguments?] = []

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didUpdateCVC cvc: String, isValid: Bool) {
        savedCardPresenterPresenterCvcCallsCount += 1
        let arguments = (presenter, cvc, isValid)
        savedCardPresenterPresenterCvcReceivedArguments = arguments
        savedCardPresenterPresenterCvcReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SavedCardViewPresenterOutputMock {
    func fullReset() {
        savedCardPresenterPresenterPaymentCardCallsCount = 0
        savedCardPresenterPresenterPaymentCardReceivedArguments = nil
        savedCardPresenterPresenterPaymentCardReceivedInvocations = []

        savedCardPresenterPresenterCvcCallsCount = 0
        savedCardPresenterPresenterCvcReceivedArguments = nil
        savedCardPresenterPresenterCvcReceivedInvocations = []
    }
}
