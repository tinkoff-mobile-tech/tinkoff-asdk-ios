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

    var underlyingIsValid = false
    var cardId: String?
    var cvc: String?

    // MARK: - savedCardViewDidBeginCVCFieldEditing

    var savedCardViewDidBeginCVCFieldEditingCallsCount = 0

    func savedCardViewDidBeginCVCFieldEditing() {
        savedCardViewDidBeginCVCFieldEditingCallsCount += 1
    }

    // MARK: - savedCardView

    typealias SavedCardViewArguments = String

    var savedCardViewCallsCount = 0
    var savedCardViewReceivedArguments: SavedCardViewArguments?
    var savedCardViewReceivedInvocations: [SavedCardViewArguments?] = []

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

    typealias UpdatePresentationStateArguments = [PaymentCard]

    var updatePresentationStateCallsCount = 0
    var updatePresentationStateReceivedArguments: UpdatePresentationStateArguments?
    var updatePresentationStateReceivedInvocations: [UpdatePresentationStateArguments?] = []

    func updatePresentationState(for cards: [PaymentCard]) {
        updatePresentationStateCallsCount += 1
        let arguments = cards
        updatePresentationStateReceivedArguments = arguments
        updatePresentationStateReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension SavedCardViewOutputMock {
    func fullReset() {
        savedCardViewDidBeginCVCFieldEditingCallsCount = 0

        savedCardViewCallsCount = 0
        savedCardViewReceivedArguments = nil
        savedCardViewReceivedInvocations = []

        savedCardViewIsSelectedCallsCount = 0

        activateCVCFieldCallsCount = 0

        updatePresentationStateCallsCount = 0
        updatePresentationStateReceivedArguments = nil
        updatePresentationStateReceivedInvocations = []
    }
}
