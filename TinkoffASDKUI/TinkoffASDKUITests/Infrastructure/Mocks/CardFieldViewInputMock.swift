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

    typealias UpdateDynamicCardViewArguments = DynamicIconCardView.Model

    var updateDynamicCardViewCallsCount = 0
    var updateDynamicCardViewReceivedArguments: UpdateDynamicCardViewArguments?
    var updateDynamicCardViewReceivedInvocations: [UpdateDynamicCardViewArguments?] = []

    func updateDynamicCardView(with model: DynamicIconCardView.Model) {
        updateDynamicCardViewCallsCount += 1
        let arguments = model
        updateDynamicCardViewReceivedArguments = arguments
        updateDynamicCardViewReceivedInvocations.append(arguments)
    }

    // MARK: - updateCardNumberField

    typealias UpdateCardNumberFieldArguments = String

    var updateCardNumberFieldCallsCount = 0
    var updateCardNumberFieldReceivedArguments: UpdateCardNumberFieldArguments?
    var updateCardNumberFieldReceivedInvocations: [UpdateCardNumberFieldArguments?] = []
    var updateCardNumberFieldReturnValue = false

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

    typealias SetCardNumberTextFieldArguments = UITextField.ViewMode

    var setCardNumberTextFieldCallsCount = 0
    var setCardNumberTextFieldReceivedArguments: SetCardNumberTextFieldArguments?
    var setCardNumberTextFieldReceivedInvocations: [SetCardNumberTextFieldArguments?] = []

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
    var setReceivedInvocations: [SetArguments?] = []

    func set(textFieldType: CardFieldType, text: String?) {
        setCallsCount += 1
        let arguments = (textFieldType, text)
        setReceivedArguments = arguments
        setReceivedInvocations.append(arguments)
    }

    // MARK: - setHeaderErrorFor

    typealias SetHeaderErrorForArguments = CardFieldType

    var setHeaderErrorForCallsCount = 0
    var setHeaderErrorForReceivedArguments: SetHeaderErrorForArguments?
    var setHeaderErrorForReceivedInvocations: [SetHeaderErrorForArguments?] = []

    func setHeaderErrorFor(textFieldType: CardFieldType) {
        setHeaderErrorForCallsCount += 1
        let arguments = textFieldType
        setHeaderErrorForReceivedArguments = arguments
        setHeaderErrorForReceivedInvocations.append(arguments)
    }

    // MARK: - setHeaderNormalFor

    typealias SetHeaderNormalForArguments = CardFieldType

    var setHeaderNormalForCallsCount = 0
    var setHeaderNormalForReceivedArguments: SetHeaderNormalForArguments?
    var setHeaderNormalForReceivedInvocations: [SetHeaderNormalForArguments?] = []

    func setHeaderNormalFor(textFieldType: CardFieldType) {
        setHeaderNormalForCallsCount += 1
        let arguments = textFieldType
        setHeaderNormalForReceivedArguments = arguments
        setHeaderNormalForReceivedInvocations.append(arguments)
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

    // MARK: - deactivate

    var deactivateCallsCount = 0

    func deactivate() {
        deactivateCallsCount += 1
    }
}

// MARK: - Resets

extension CardFieldViewInputMock {
    func fullReset() {
        updateDynamicCardViewCallsCount = 0
        updateDynamicCardViewReceivedArguments = nil
        updateDynamicCardViewReceivedInvocations = []

        updateCardNumberFieldCallsCount = 0
        updateCardNumberFieldReceivedArguments = nil
        updateCardNumberFieldReceivedInvocations = []

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
