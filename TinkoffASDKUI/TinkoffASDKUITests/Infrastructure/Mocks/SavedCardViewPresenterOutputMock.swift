//
//  SavedCardViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SavedCardViewPresenterOutputMock: ISavedCardViewPresenterOutput {

    // MARK: - savedCardPresenterDidRequestReplacementFor

    typealias SavedCardPresenterDidRequestReplacementForArguments = (presenter: SavedCardViewPresenter, paymentCard: PaymentCard)

    var savedCardPresenterDidRequestReplacementForCallsCount = 0
    var savedCardPresenterDidRequestReplacementForReceivedArguments: SavedCardPresenterDidRequestReplacementForArguments?
    var savedCardPresenterDidRequestReplacementForReceivedInvocations: [SavedCardPresenterDidRequestReplacementForArguments?] = []

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didRequestReplacementFor paymentCard: PaymentCard) {
        savedCardPresenterDidRequestReplacementForCallsCount += 1
        let arguments = (presenter, paymentCard)
        savedCardPresenterDidRequestReplacementForReceivedArguments = arguments
        savedCardPresenterDidRequestReplacementForReceivedInvocations.append(arguments)
    }

    // MARK: - savedCardPresenterDidUpdateCVC

    typealias SavedCardPresenterDidUpdateCVCArguments = (presenter: SavedCardViewPresenter, cvc: String, isValid: Bool)

    var savedCardPresenterDidUpdateCVCCallsCount = 0
    var savedCardPresenterDidUpdateCVCReceivedArguments: SavedCardPresenterDidUpdateCVCArguments?
    var savedCardPresenterDidUpdateCVCReceivedInvocations: [SavedCardPresenterDidUpdateCVCArguments?] = []

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didUpdateCVC cvc: String, isValid: Bool) {
        savedCardPresenterDidUpdateCVCCallsCount += 1
        let arguments = (presenter, cvc, isValid)
        savedCardPresenterDidUpdateCVCReceivedArguments = arguments
        savedCardPresenterDidUpdateCVCReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SavedCardViewPresenterOutputMock {
    func fullReset() {
        savedCardPresenterDidRequestReplacementForCallsCount = 0
        savedCardPresenterDidRequestReplacementForReceivedArguments = nil
        savedCardPresenterDidRequestReplacementForReceivedInvocations = []

        savedCardPresenterDidUpdateCVCCallsCount = 0
        savedCardPresenterDidUpdateCVCReceivedArguments = nil
        savedCardPresenterDidUpdateCVCReceivedInvocations = []
    }
}
