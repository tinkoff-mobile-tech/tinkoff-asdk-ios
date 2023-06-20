//
//  SavedCardViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 23.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SavedCardViewOutputMock: ISavedCardViewOutput {
    var view: ISavedCardViewInput?
    var presentationState: SavedCardPresentationState {
        get { return underlyingPresentationState }
        set(value) { underlyingPresentationState = value }
    }

    var underlyingPresentationState: SavedCardPresentationState = .idle
    var isValid: Bool {
        get { return underlyingIsValid }
        set(value) { underlyingIsValid = value }
    }

    var underlyingIsValid: Bool = false
    var cardId: String?
    var cvc: String?

    // MARK: - savedCardViewDidBeginCVCFieldEditing

    var savedCardViewDidBeginCVCFieldEditingCallsCount = 0

    func savedCardViewDidBeginCVCFieldEditing() {
        savedCardViewDidBeginCVCFieldEditingCallsCount += 1
    }

    // MARK: - savedCardView

    var savedCardViewCallsCount = 0
    var savedCardViewReceivedArguments: String?
    var savedCardViewReceivedInvocations: [String] = []

    func savedCardView(didChangeCVC cvcInputText: String) {
        savedCardViewCallsCount += 1
        let arguments = cvcInputText
        savedCardViewReceivedArguments = arguments
        savedCardViewReceivedInvocations.append(arguments)
    }

    // MARK: - savedCardViewIsSelected

    var savedCardViewIsSelectedCallsCount = 0

    func savedCardViewIsSelected() {
        savedCardViewIsSelectedCallsCount += 1
    }

    // MARK: - activateCVCField

    var activateCVCFieldCallsCount = 0

    func activateCVCField() {
        activateCVCFieldCallsCount += 1
    }

    // MARK: - updatePresentationState

    var updatePresentationStateCallsCount = 0
    var updatePresentationStateReceivedArguments: [PaymentCard]?
    var updatePresentationStateReceivedInvocations: [[PaymentCard]] = []

    func updatePresentationState(for cards: [PaymentCard]) {
        updatePresentationStateCallsCount += 1
        let arguments = cards
        updatePresentationStateReceivedArguments = arguments
        updatePresentationStateReceivedInvocations.append(arguments)
    }
}
