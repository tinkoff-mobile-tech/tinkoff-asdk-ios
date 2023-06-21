//
//  CardFieldViewInputMock.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 31.05.2023.
//

@testable import TinkoffASDKUI
import UIKit

final class CardFieldViewInputMock: ICardFieldViewInput {

    // MARK: - updateDynamicCardView

    var updateDynamicCardViewCallsCount = 0
    var updateDynamicCardViewReceivedArguments: DynamicIconCardView.Model?
    var updateDynamicCardViewReceivedInvocations: [DynamicIconCardView.Model] = []

    func updateDynamicCardView(with model: DynamicIconCardView.Model) {
        updateDynamicCardViewCallsCount += 1
        let arguments = model
        updateDynamicCardViewReceivedArguments = arguments
        updateDynamicCardViewReceivedInvocations.append(arguments)
    }

    // MARK: - updateCardNumberField

    var updateCardNumberFieldCallsCount = 0
    var updateCardNumberFieldReceivedArguments: String?
    var updateCardNumberFieldReceivedInvocations: [String] = []
    var updateCardNumberFieldReturnValue: Bool = false

    func updateCardNumberField(with maskFormat: String) -> Bool {
        updateCardNumberFieldCallsCount += 1
        let arguments = maskFormat
        updateCardNumberFieldReceivedArguments = arguments
        updateCardNumberFieldReceivedInvocations.append(arguments)
        return updateCardNumberFieldReturnValue
    }

    // MARK: - activateScanButton

    var activateScanButtonCallsCount = 0

    func activateScanButton() {
        activateScanButtonCallsCount += 1
    }

    // MARK: - setCardNumberTextField

    var setCardNumberTextFieldCallsCount = 0
    var setCardNumberTextFieldReceivedArguments: UITextField.ViewMode?
    var setCardNumberTextFieldReceivedInvocations: [UITextField.ViewMode] = []

    func setCardNumberTextField(rightViewMode: UITextField.ViewMode) {
        setCardNumberTextFieldCallsCount += 1
        let arguments = rightViewMode
        setCardNumberTextFieldReceivedArguments = arguments
        setCardNumberTextFieldReceivedInvocations.append(arguments)
    }

    // MARK: - set

    typealias SetArguments = (textFieldType: CardFieldType, text: String?)

    var setCallsCount = 0
    var setReceivedArguments: SetArguments?
    var setReceivedInvocations: [SetArguments] = []

    func set(textFieldType: CardFieldType, text: String?) {
        setCallsCount += 1
        let arguments = (textFieldType, text)
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }

    // MARK: - setHeaderErrorFor

    var setHeaderErrorForCallsCount = 0
    var setHeaderErrorForReceivedArguments: CardFieldType?
    var setHeaderErrorForReceivedInvocations: [CardFieldType] = []

    func setHeaderErrorFor(textFieldType: CardFieldType) {
        setHeaderErrorForCallsCount += 1
        let arguments = textFieldType
        setHeaderErrorForReceivedArguments = arguments
        setHeaderErrorForReceivedInvocations.append(arguments)
    }

    // MARK: - setHeaderNormalFor

    var setHeaderNormalForCallsCount = 0
    var setHeaderNormalForReceivedArguments: CardFieldType?
    var setHeaderNormalForReceivedInvocations: [CardFieldType] = []

    func setHeaderNormalFor(textFieldType: CardFieldType) {
        setHeaderNormalForCallsCount += 1
        let arguments = textFieldType
        setHeaderNormalForReceivedArguments = arguments
        setHeaderNormalForReceivedInvocations.append(arguments)
    }

    // MARK: - activate

    var activateCallsCount = 0
    var activateReceivedArguments: CardFieldType?
    var activateReceivedInvocations: [CardFieldType] = []

    func activate(textFieldType: CardFieldType) {
        activateCallsCount += 1
        let arguments = textFieldType
        activateReceivedArguments = arguments
        activateReceivedInvocations.append(arguments)
    }

    // MARK: - deactivate

    var deactivateCallsCount = 0

    func deactivate() {
        deactivateCallsCount += 1
    }
}

// MARK: - Public methods

extension CardFieldViewInputMock {
    func fullReset() {
        updateDynamicCardViewCallsCount = 0
        updateDynamicCardViewReceivedArguments = nil
        updateDynamicCardViewReceivedInvocations = []

        updateCardNumberFieldCallsCount = 0
        updateCardNumberFieldReceivedArguments = nil
        updateCardNumberFieldReceivedInvocations = []
        updateCardNumberFieldReturnValue = false

        activateScanButtonCallsCount = 0

        setCardNumberTextFieldCallsCount = 0
        setCardNumberTextFieldReceivedArguments = nil
        setCardNumberTextFieldReceivedInvocations = []

        setCallsCount = 0
        setReceivedArguments = nil
        setReceivedInvocations = []

        setHeaderErrorForCallsCount = 0
        setHeaderErrorForReceivedArguments = nil
        setHeaderErrorForReceivedInvocations = []

        setHeaderNormalForCallsCount = 0
        setHeaderNormalForReceivedArguments = nil
        setHeaderNormalForReceivedInvocations = []

        activateCallsCount = 0
        activateReceivedArguments = nil
        activateReceivedInvocations = []

        deactivateCallsCount = 0
    }
}
