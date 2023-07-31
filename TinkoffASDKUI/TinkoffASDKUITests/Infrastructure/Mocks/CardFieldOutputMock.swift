//
//  CardFieldOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 31.05.2023.
//

@testable import TinkoffASDKUI

final class CardFieldOutputMock: ICardFieldOutput {

    // MARK: - scanButtonPressed

    var scanButtonPressedCallsCount = 0

    func scanButtonPressed() {
        scanButtonPressedCallsCount += 1
    }

    // MARK: - cardFieldValidationResultDidChange

    typealias CardFieldValidationResultDidChangeArguments = CardFieldValidationResult

    var cardFieldValidationResultDidChangeCallsCount = 0
    var cardFieldValidationResultDidChangeReceivedArguments: CardFieldValidationResultDidChangeArguments?
    var cardFieldValidationResultDidChangeReceivedInvocations: [CardFieldValidationResultDidChangeArguments?] = []

    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        cardFieldValidationResultDidChangeCallsCount += 1
        let arguments = result
        cardFieldValidationResultDidChangeReceivedArguments = arguments
        cardFieldValidationResultDidChangeReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CardFieldOutputMock {
    func fullReset() {
        scanButtonPressedCallsCount = 0

        cardFieldValidationResultDidChangeCallsCount = 0
        cardFieldValidationResultDidChangeReceivedArguments = nil
        cardFieldValidationResultDidChangeReceivedInvocations = []
    }
}
