//
//  2322321.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

@testable import TinkoffASDKUI

final class CardFieldViewOutputMock: CardFieldInputMock, ICardFieldViewOutput {

    var view: ICardFieldViewInput?

    // MARK: - scanButton

    var scanButtonPressedCallsCount = 0

    func scanButtonPressed() {
        scanButtonPressedCallsCount += 1
    }

    // MARK: - didFillField

    typealias DidFillFieldArguments = (type: CardFieldType, text: String, filled: Bool)

    var didFillFieldCallsCount = 0
    var didFillFieldReceivedArguments: DidFillFieldArguments?
    var didFillFieldReceivedInvocations: [DidFillFieldArguments] = []

    func didFillField(type: CardFieldType, text: String, filled: Bool) {
        didFillFieldCallsCount += 1
        let arguments = (type, text, filled)
        didFillFieldReceivedArguments = arguments
        didFillFieldReceivedInvocations.append(arguments)
    }

    // MARK: - didBeginEditing

    var didBeginEditingCallsCount = 0
    var didBeginEditingReceivedArguments: CardFieldType?
    var didBeginEditingReceivedInvocations: [CardFieldType] = []

    func didBeginEditing(fieldType: CardFieldType) {
        didBeginEditingCallsCount += 1
        let arguments = fieldType
        didBeginEditingReceivedArguments = arguments
        didBeginEditingReceivedInvocations.append(arguments)
    }

    // MARK: - didEndEditing

    var didEndEditingCallsCount = 0
    var didEndEditingReceivedArguments: CardFieldType?
    var didEndEditingReceivedInvocations: [CardFieldType] = []

    func didEndEditing(fieldType: CardFieldType) {
        didEndEditingCallsCount += 1
        let arguments = fieldType
        didEndEditingReceivedArguments = arguments
        didEndEditingReceivedInvocations.append(arguments)
    }
}
