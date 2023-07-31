//
//  CardFieldViewOutputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKUI

final class CardFieldViewOutputMock: CardFieldInputMock, ICardFieldViewOutput {
    var view: ICardFieldViewInput?

    // MARK: - scanButtonPressed

    var scanButtonPressedCallsCount = 0

    func scanButtonPressed() {
        scanButtonPressedCallsCount += 1
    }

    // MARK: - didFillField

    typealias DidFillFieldArguments = (type: CardFieldType, text: String, filled: Bool)

    var didFillFieldCallsCount = 0
    var didFillFieldReceivedArguments: DidFillFieldArguments?
    var didFillFieldReceivedInvocations: [DidFillFieldArguments?] = []

    func didFillField(type: CardFieldType, text: String, filled: Bool) {
        didFillFieldCallsCount += 1
        let arguments = (type, text, filled)
        didFillFieldReceivedArguments = arguments
        didFillFieldReceivedInvocations.append(arguments)
    }

    // MARK: - didBeginEditing

    typealias DidBeginEditingArguments = CardFieldType

    var didBeginEditingCallsCount = 0
    var didBeginEditingReceivedArguments: DidBeginEditingArguments?
    var didBeginEditingReceivedInvocations: [DidBeginEditingArguments?] = []

    func didBeginEditing(fieldType: CardFieldType) {
        didBeginEditingCallsCount += 1
        let arguments = fieldType
        didBeginEditingReceivedArguments = arguments
        didBeginEditingReceivedInvocations.append(arguments)
    }

    // MARK: - didEndEditing

    typealias DidEndEditingArguments = CardFieldType

    var didEndEditingCallsCount = 0
    var didEndEditingReceivedArguments: DidEndEditingArguments?
    var didEndEditingReceivedInvocations: [DidEndEditingArguments?] = []

    func didEndEditing(fieldType: CardFieldType) {
        didEndEditingCallsCount += 1
        let arguments = fieldType
        didEndEditingReceivedArguments = arguments
        didEndEditingReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CardFieldViewOutputMock {
    override func fullReset() {
        super.fullReset()

        scanButtonPressedCallsCount = 0

        didFillFieldCallsCount = 0
        didFillFieldReceivedArguments = nil
        didFillFieldReceivedInvocations = []

        didBeginEditingCallsCount = 0
        didBeginEditingReceivedArguments = nil
        didBeginEditingReceivedInvocations = []

        didEndEditingCallsCount = 0
        didEndEditingReceivedArguments = nil
        didEndEditingReceivedInvocations = []

        validateWholeFormCallsCount = 0
    }
}
