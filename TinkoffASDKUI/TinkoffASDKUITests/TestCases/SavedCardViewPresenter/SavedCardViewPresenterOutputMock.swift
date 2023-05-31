//
//  SavedCardViewPresenterOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SavedCardViewPresenterOutputMock: ISavedCardViewPresenterOutput {

    // MARK: - didRequestReplacement

    typealias DidRequestReplacementArguments = (presenter: SavedCardViewPresenter, paymentCard: PaymentCard)

    var didRequestReplacementForCallsCount = 0
    var didRequestReplacementReceivedArguments: DidRequestReplacementArguments?
    var didRequestReplacementReceivedInvocations: [DidRequestReplacementArguments] = []

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didRequestReplacementFor paymentCard: PaymentCard) {
        didRequestReplacementForCallsCount += 1
        let arguments = (presenter, paymentCard)
        didRequestReplacementReceivedArguments = arguments
        didRequestReplacementReceivedInvocations.append(arguments)
    }

    // MARK: - didUpdateCVC

    typealias DidUpdateCVCArguments = (presenter: SavedCardViewPresenter, cvc: String, isValid: Bool)

    var didUpdateCVCCallsCount = 0
    var didUpdateCVCReceivedArguments: DidUpdateCVCArguments?
    var didUpdateCVCReceivedInvocations: [DidUpdateCVCArguments] = []

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didUpdateCVC cvc: String, isValid: Bool) {
        didUpdateCVCCallsCount += 1
        let arguments = (presenter, cvc, isValid)
        didUpdateCVCReceivedArguments = arguments
        didUpdateCVCReceivedInvocations.append(arguments)
    }
}

// MARK: - Public methods

extension SavedCardViewPresenterOutputMock {
    func fullReset() {
        didRequestReplacementForCallsCount = 0
        didRequestReplacementReceivedArguments = nil
        didRequestReplacementReceivedInvocations = []

        didUpdateCVCCallsCount = 0
        didUpdateCVCReceivedArguments = nil
        didUpdateCVCReceivedInvocations = []
    }
}
