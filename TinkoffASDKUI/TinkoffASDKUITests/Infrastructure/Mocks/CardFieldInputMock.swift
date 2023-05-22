//
//  CardFieldInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 27.03.2023.
//

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

    var setTextFieldTypeCallsCount = 0
    var setTextFieldTypeReceivedArguments: (CardFieldType, String?)?
    var setTextFieldTypeReceivedInvocations: [(CardFieldType, String?)] = []
    func set(textFieldType: CardFieldType, text: String?) {
        setTextFieldTypeCallsCount += 1
        let arguments = (textFieldType, text)
        setTextFieldTypeReceivedArguments = arguments
        setTextFieldTypeReceivedInvocations.append(arguments)
    }

    var activateTextFieldTypeCallsCount = 0
    var activateTextFieldTypeReceivedArguments: CardFieldType?
    var activateTextFieldTypeReceivedInvocations: [CardFieldType] = []
    func activate(textFieldType: CardFieldType) {
        activateTextFieldTypeCallsCount += 1
        let arguments = textFieldType
        activateTextFieldTypeReceivedArguments = arguments
        activateTextFieldTypeReceivedInvocations.append(arguments)
    }

    var validationResult: CardFieldValidationResult {
        get { return underlyingValidationResult }
        set(value) { underlyingValidationResult = value }
    }

    var underlyingValidationResult: CardFieldValidationResult!

    // MARK: - validateWholeForm

    var validateWholeFormCallsCount = 0
    var validateWholeFormReturnValue = CardFieldValidationResult()

    @discardableResult
    func validateWholeForm() -> CardFieldValidationResult {
        validateWholeFormCallsCount += 1
        return validateWholeFormReturnValue
    }
    
    // MARK: - injectOutput

    var injectOutputCallsCount = 0
    var injectOutputReceivedArguments: ICardFieldOutput?
    var injectOutputReceivedInvocations: [ICardFieldOutput] = []

    func injectOutput(_ output: ICardFieldOutput) {
        injectOutputCallsCount += 1
        let arguments = (output)
        injectOutputReceivedArguments = arguments
        injectOutputReceivedInvocations.append(arguments)
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
