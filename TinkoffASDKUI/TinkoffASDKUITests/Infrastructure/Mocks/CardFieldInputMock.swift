//
//  CardFieldInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

import Foundation
@testable import TinkoffASDKUI

class CardFieldInputMock: ICardFieldInput {

    var cardData: CardData {
        get { return underlyingCardData }
        set(value) { underlyingCardData = value }
    }

    var underlyingCardData: CardData!

    var cardNumber: String {
        get { return underlyingCardNumber }
        set(value) { underlyingCardNumber = value }
    }

    var underlyingCardNumber: String!

    var expiration: String {
        get { return underlyingExpiration }
        set(value) { underlyingExpiration = value }
    }

    var underlyingExpiration: String!

    var cvc: String {
        get { return underlyingCvc }
        set(value) { underlyingCvc = value }
    }

    var underlyingCvc: String!

    var validationResult: CardFieldValidationResult {
        get { return underlyingValidationResult }
        set(value) { underlyingValidationResult = value }
    }

    var underlyingValidationResult: CardFieldValidationResult!

    // MARK: - set

    typealias SetArguments = (textFieldType: CardFieldType, text: String?)

    var setCallsCount = 0
    var setReceivedArguments: SetArguments?
    var setReceivedInvocations: [SetArguments?] = []

    func set(textFieldType: CardFieldType, text: String?) {
        setCallsCount += 1
        let arguments = (textFieldType, text)
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }

    // MARK: - activate

    typealias ActivateArguments = CardFieldType

    var activateCallsCount = 0
    var activateReceivedArguments: ActivateArguments?
    var activateReceivedInvocations: [ActivateArguments?] = []

    func activate(textFieldType: CardFieldType) {
        activateCallsCount += 1
        let arguments = textFieldType
        activateReceivedArguments = arguments
        activateReceivedInvocations.append(arguments)
    }

    // MARK: - validateWholeForm

    var validateWholeFormCallsCount = 0
    var validateWholeFormReturnValue = CardFieldValidationResult()

    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult {
        validateWholeFormCallsCount += 1
        return validateWholeFormReturnValue
    }

    // MARK: - injectOutput

    typealias InjectOutputArguments = ICardFieldOutput

    var injectOutputCallsCount = 0
    var injectOutputReceivedArguments: InjectOutputArguments?
    var injectOutputReceivedInvocations: [InjectOutputArguments?] = []

    func injectOutput(_ output: ICardFieldOutput) {
        injectOutputCallsCount += 1
        let arguments = output
        injectOutputReceivedArguments = arguments
        injectOutputReceivedInvocations.append(arguments)
    }
}

// MARK: - Resets

extension CardFieldInputMock {
    @objc func fullReset() {
        setCallsCount = 0
        setReceivedArguments = nil
        setReceivedInvocations = []

        activateCallsCount = 0
        activateReceivedArguments = nil
        activateReceivedInvocations = []

        validateWholeFormCallsCount = 0

        injectOutputCallsCount = 0
        injectOutputReceivedArguments = nil
        injectOutputReceivedInvocations = []
    }
}

extension CardFieldInputMock {

    func bootstrap() {
        underlyingCardNumber = "2201382000000104"
        underlyingCvc = "111"
        underlyingExpiration = "0928"
        underlyingCardData = CardData(
            cardNumber: underlyingCardNumber,
            expiration: underlyingExpiration,
            cvc: underlyingCvc
        )
    }
}
