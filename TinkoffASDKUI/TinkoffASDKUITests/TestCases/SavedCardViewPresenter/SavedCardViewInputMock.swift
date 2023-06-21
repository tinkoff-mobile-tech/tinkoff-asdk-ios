//
//  SavedCardViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

@testable import TinkoffASDKUI

final class SavedCardViewInputMock: ISavedCardViewInput {

    // MARK: - update

    var updateCallsCount = 0
    var updateReceivedArguments: SavedCardViewModel?
    var updateReceivedInvocations: [SavedCardViewModel] = []

    func update(with viewModel: SavedCardViewModel) {
        updateCallsCount += 1
        let arguments = viewModel
        updateReceivedArguments = arguments
        updateReceivedInvocations.append(arguments)
    }

    // MARK: - showCVCField

    var showCVCFieldCallsCount = 0

    func showCVCField() {
        showCVCFieldCallsCount += 1
    }

    // MARK: - hideCVCField

    var hideCVCFieldCallsCount = 0

    func hideCVCField() {
        hideCVCFieldCallsCount += 1
    }

    // MARK: - setCVCText

    var setCVCTextCallsCount = 0
    var setCVCTextReceivedArguments: String?
    var setCVCTextReceivedInvocations: [String] = []

    func setCVCText(_ text: String) {
        setCVCTextCallsCount += 1
        let arguments = text
        setCVCTextReceivedArguments = arguments
        setCVCTextReceivedInvocations.append(arguments)
    }

    // MARK: - setCVCFieldValid

    var setCVCFieldValidCallsCount = 0

    func setCVCFieldValid() {
        setCVCFieldValidCallsCount += 1
    }

    // MARK: - setCVCFieldInvalid

    var setCVCFieldInvalidCallsCount = 0

    func setCVCFieldInvalid() {
        setCVCFieldInvalidCallsCount += 1
    }

    // MARK: - activateCVCField

    var activateCVCFieldCallsCount = 0

    func activateCVCField() {
        activateCVCFieldCallsCount += 1
    }

    // MARK: - deactivateCVCField

    var deactivateCVCFieldCallsCount = 0

    func deactivateCVCField() {
        deactivateCVCFieldCallsCount += 1
    }
}

// MARK: - Public methods

extension SavedCardViewInputMock {
    func fullReset() {
        updateCallsCount = 0
        updateReceivedArguments = nil
        updateReceivedInvocations = []

        showCVCFieldCallsCount = 0
        hideCVCFieldCallsCount = 0

        setCVCTextCallsCount = 0
        setCVCTextReceivedArguments = nil
        setCVCTextReceivedInvocations = []

        setCVCFieldValidCallsCount = 0
        setCVCFieldInvalidCallsCount = 0
        activateCVCFieldCallsCount = 0
        deactivateCVCFieldCallsCount = 0
    }
}
