//
//  CardFieldPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 31.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardFieldPresenterTests: BaseTestCase {

    var sut: CardFieldPresenter!

    // MARK: Mocks

    var viewMock: CardFieldViewInputMock!
    var validatorMock: CardRequisitesValidatorMock!
    var paymentSystemResolverMock: PaymentSystemResolverMock!
    var bankResolverMock: BankResolverMock!
    var inputMaskResolverMock: CardRequisitesMasksResolverMock!
    var outputMock: CardFieldOutputMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        validatorMock = nil
        paymentSystemResolverMock = nil
        bankResolverMock = nil
        inputMaskResolverMock = nil
        outputMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_validateWholeForm_when_allValid_3_fieldsForValidate() {
        // given
        sut.didEndEditing(fieldType: .cvc)

        validatorMock.fullReset()
        outputMock.fullReset()

        validatorMock.validateInputPANReturnValue = true
        validatorMock.validateValidThruYearReturnValue = true
        validatorMock.validateInputValidThruYearReturnValue = true
        validatorMock.validateInputCVCReturnValue = true

        // when
        let result = sut.validateWholeForm()

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeReceivedArguments, result)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 3)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 0)
        XCTAssertEqual(result.isValid, true)
    }

    func test_validateWholeForm_when_notAllValid_2_fieldsForValidate() {
        // given
        sut.didEndEditing(fieldType: .expiration)

        validatorMock.fullReset()
        outputMock.fullReset()

        validatorMock.validateInputPANReturnValue = false
        validatorMock.validateValidThruYearReturnValue = true
        validatorMock.validateInputValidThruYearReturnValue = true
        validatorMock.validateInputCVCReturnValue = true

        // when
        let result = sut.validateWholeForm()

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeReceivedArguments, result)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 1)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 1)
        XCTAssertEqual(result.isValid, false)
    }

    func test_validateWholeForm_when_allValid_1_fieldsForValidate() {
        // given
        sut.didEndEditing(fieldType: .cardNumber)

        validatorMock.fullReset()
        outputMock.fullReset()

        validatorMock.validateInputPANReturnValue = true
        validatorMock.validateValidThruYearReturnValue = true
        validatorMock.validateInputValidThruYearReturnValue = true
        validatorMock.validateInputCVCReturnValue = true

        // when
        let result = sut.validateWholeForm()

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeReceivedArguments, result)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 1)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 0)
        XCTAssertEqual(result.isValid, true)
    }

    func test_validateWholeForm_when_allValid_0_fieldsForValidate() {
        // given
        validatorMock.validateInputPANReturnValue = true
        validatorMock.validateValidThruYearReturnValue = true
        validatorMock.validateInputValidThruYearReturnValue = true
        validatorMock.validateInputCVCReturnValue = true

        // when
        let result = sut.validateWholeForm()

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeReceivedArguments, result)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 0)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 0)
        XCTAssertEqual(result.isValid, true)
    }

    func test_didFillField_cardNumber_isUpdatedCardNumber_textEmpty() {
        // given
        setupSut(isScanButtonNeeded: true)

        let text = ""
        let isFilled = true
        viewMock.updateCardNumberFieldReturnValue = true

        // when
        sut.didFillField(type: .cardNumber, text: text, filled: isFilled)

        // then
        XCTAssertEqual(inputMaskResolverMock.panMaskCallsCount, 1)
        XCTAssertEqual(viewMock.updateCardNumberFieldCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldReceivedArguments, .unlessEditing)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(viewMock.updateDynamicCardViewCallsCount, 1)
        XCTAssertEqual(viewMock.activateCallsCount, 1)
        XCTAssertEqual(viewMock.activateReceivedArguments, .expiration)
    }

    func test_didFillField_cardNumber_notUpdatedCardNumber_textExist() {
        // given
        setupSut(isScanButtonNeeded: true)

        let text = "1234567812345678"
        let isFilled = false
        viewMock.updateCardNumberFieldReturnValue = false

        // when
        sut.didFillField(type: .cardNumber, text: text, filled: isFilled)

        // then
        XCTAssertEqual(inputMaskResolverMock.panMaskCallsCount, 1)
        XCTAssertEqual(viewMock.updateCardNumberFieldCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldReceivedArguments, .never)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(viewMock.updateDynamicCardViewCallsCount, 1)
        XCTAssertEqual(viewMock.activateCallsCount, 0)
    }

    func test_didFillField_cardNumber_notUpdatedCardNumber_textExist_notNeededScanButton() {
        // given
        setupSut(isScanButtonNeeded: false)

        let text = "1234567812345678"
        let isFilled = false
        viewMock.updateCardNumberFieldReturnValue = false

        // when
        sut.didFillField(type: .cardNumber, text: text, filled: isFilled)

        // then
        XCTAssertEqual(inputMaskResolverMock.panMaskCallsCount, 1)
        XCTAssertEqual(viewMock.updateCardNumberFieldCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldCallsCount, 0)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(viewMock.updateDynamicCardViewCallsCount, 1)
        XCTAssertEqual(viewMock.activateCallsCount, 0)
    }

    func test_didFillField_cardNumber_viewNil() {
        // given
        sut.view = nil

        let text = "1234567812345678"
        let isFilled = false
        viewMock.updateCardNumberFieldReturnValue = false

        // when
        sut.didFillField(type: .cardNumber, text: text, filled: isFilled)

        // then
        XCTAssertEqual(inputMaskResolverMock.panMaskCallsCount, 1)
        XCTAssertEqual(viewMock.updateCardNumberFieldCallsCount, 0)
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldCallsCount, 0)
        XCTAssertEqual(bankResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallsCount, 1)
        XCTAssertEqual(viewMock.updateDynamicCardViewCallsCount, 0)
        XCTAssertEqual(viewMock.activateCallsCount, 0)
    }

    func test_didFillField_expiration_when_filled() {
        // when
        sut.didFillField(type: .expiration, text: "1234", filled: true)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.activateCallsCount, 1)
        XCTAssertEqual(viewMock.activateReceivedArguments, .cvc)
    }

    func test_didFillField_expiration_when_notFilled() {
        // when
        sut.didFillField(type: .expiration, text: "1234", filled: false)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.activateCallsCount, 0)
    }

    func test_didFillField_cvc() {
        // when
        sut.didFillField(type: .cvc, text: "111", filled: true)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.activateCallsCount, 0)
    }

    func test_didBeginEditing_cardNumber() {
        // given
        let fieldType = CardFieldType.cardNumber
        sut.didEndEditing(fieldType: .cvc)

        validatorMock.fullReset()
        outputMock.fullReset()

        validatorMock.validateInputPANReturnValue = true
        validatorMock.validateValidThruYearReturnValue = true
        validatorMock.validateInputValidThruYearReturnValue = true
        validatorMock.validateInputCVCReturnValue = true

        // when
        sut.didBeginEditing(fieldType: fieldType)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 4)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[0], .cardNumber)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[1], .expiration)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[2], .cvc)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[3], fieldType)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 0)
    }

    func test_didBeginEditing_expiration() {
        // given
        let fieldType = CardFieldType.expiration
        sut.didEndEditing(fieldType: .cvc)

        validatorMock.fullReset()
        outputMock.fullReset()

        validatorMock.validateInputPANReturnValue = true
        validatorMock.validateValidThruYearReturnValue = true
        validatorMock.validateInputValidThruYearReturnValue = true
        validatorMock.validateInputCVCReturnValue = false

        // when
        sut.didBeginEditing(fieldType: fieldType)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 3)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[0], .cardNumber)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[1], .expiration)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[2], fieldType)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 1)
    }

    func test_didBeginEditing_cvc() {
        // given
        let fieldType = CardFieldType.cvc
        sut.didEndEditing(fieldType: .cvc)

        validatorMock.fullReset()
        outputMock.fullReset()

        validatorMock.validateInputPANReturnValue = true
        validatorMock.validateValidThruYearReturnValue = false
        validatorMock.validateInputValidThruYearReturnValue = false
        validatorMock.validateInputCVCReturnValue = false

        // when
        sut.didBeginEditing(fieldType: fieldType)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
        XCTAssertEqual(viewMock.setHeaderNormalForCallsCount, 2)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[0], .cardNumber)
        XCTAssertEqual(viewMock.setHeaderNormalForReceivedInvocations[1], fieldType)
        XCTAssertEqual(viewMock.setHeaderErrorForCallsCount, 2)
    }

    func test_didEndEditing() {
        // when
        sut.didEndEditing(fieldType: .expiration)

        // then
        XCTAssertEqual(validatorMock.validateInputPANCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputValidThruYearCallsCount, 1)
        XCTAssertEqual(validatorMock.validateInputCVCCallsCount, 1)
        XCTAssertEqual(outputMock.cardFieldValidationResultDidChangeCallsCount, 1)
    }

    func test_setupView_when_isScanButtonNeeded() {
        // given
        setupSut(isScanButtonNeeded: true)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.updateDynamicCardViewCallsCount, 1)
        XCTAssertEqual(viewMock.activateScanButtonCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setCardNumberTextFieldReceivedArguments, .unlessEditing)
    }

    func test_setupView_when_notScanButtonNeeded() {
        // given
        setupSut(isScanButtonNeeded: false)

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.updateDynamicCardViewCallsCount, 1)
        XCTAssertEqual(viewMock.activateScanButtonCallsCount, 0)
        XCTAssertEqual(viewMock.setCardNumberTextFieldCallsCount, 0)
    }

    func test_cardData() {
        // given
        let cardNumber = "1234567812345678"
        let expiration = "1234"
        let cvc = "111"
        sut.didFillField(type: .cardNumber, text: cardNumber, filled: true)
        sut.didFillField(type: .expiration, text: expiration, filled: true)
        sut.didFillField(type: .cvc, text: cvc, filled: true)

        let expectedCardData = CardData(cardNumber: cardNumber, expiration: expiration, cvc: cvc)

        // when
        let cardData = sut.cardData

        // then
        XCTAssertEqual(cardData, expectedCardData)
    }

    func test_injectOutput() {
        // given
        setupSut(output: nil)
        outputMock = CardFieldOutputMock()

        // when
        sut.injectOutput(outputMock)
        sut.scanButtonPressed()

        // then
        XCTAssertEqual(outputMock.scanButtonPressedCallsCount, 1)
    }

    func test_setTextFieldType_cardNumber() {
        // given
        let text = "Some text"
        let type = CardFieldType.cardNumber

        // when
        sut.set(textFieldType: type, text: text)

        // then
        XCTAssertEqual(viewMock.setCallsCount, 1)
        XCTAssertEqual(viewMock.setReceivedArguments?.textFieldType, type)
        XCTAssertEqual(viewMock.setReceivedArguments?.text, text)
    }

    func test_setTextFieldType_expiration() {
        // given
        let text = "Some text"
        let type = CardFieldType.expiration

        // when
        sut.set(textFieldType: type, text: text)

        // then
        XCTAssertEqual(viewMock.setCallsCount, 1)
        XCTAssertEqual(viewMock.setReceivedArguments?.textFieldType, type)
        XCTAssertEqual(viewMock.setReceivedArguments?.text, text)
    }

    func test_setTextFieldType_cvc() {
        // given
        let text = "Some text"
        let type = CardFieldType.cvc

        // when
        sut.set(textFieldType: type, text: text)

        // then
        XCTAssertEqual(viewMock.setCallsCount, 1)
        XCTAssertEqual(viewMock.setReceivedArguments?.textFieldType, type)
        XCTAssertEqual(viewMock.setReceivedArguments?.text, text)
    }

    func test_activateTextFieldType_cardNumber() {
        // given
        let type = CardFieldType.cardNumber

        // when
        sut.activate(textFieldType: type)

        // then
        XCTAssertEqual(viewMock.activateCallsCount, 1)
        XCTAssertEqual(viewMock.activateReceivedArguments, .cardNumber)
    }

    func test_activateTextFieldType_expiration() {
        // given
        let type = CardFieldType.expiration

        // when
        sut.activate(textFieldType: type)

        // then
        XCTAssertEqual(viewMock.activateCallsCount, 1)
        XCTAssertEqual(viewMock.activateReceivedArguments, .expiration)
    }

    func test_activateTextFieldType_cvc() {
        // given
        let type = CardFieldType.cvc

        // when
        sut.activate(textFieldType: type)

        // then
        XCTAssertEqual(viewMock.activateCallsCount, 1)
        XCTAssertEqual(viewMock.activateReceivedArguments, .cvc)
    }

    func test_scanButtonPressed() {
        // when
        sut.scanButtonPressed()

        // then
        XCTAssertEqual(outputMock.scanButtonPressedCallsCount, 1)
    }
}

// MARK: - Private methods

extension CardFieldPresenterTests {
    private func setupSut(
        isScanButtonNeeded: Bool = false,
        output: CardFieldOutputMock? = CardFieldOutputMock()
    ) {
        viewMock = CardFieldViewInputMock()
        validatorMock = CardRequisitesValidatorMock()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        bankResolverMock = BankResolverMock()
        inputMaskResolverMock = CardRequisitesMasksResolverMock()
        outputMock = output

        sut = CardFieldPresenter(
            output: outputMock,
            isScanButtonNeeded: isScanButtonNeeded,
            validator: validatorMock,
            paymentSystemResolver: paymentSystemResolverMock,
            bankResolver: bankResolverMock,
            inputMaskResolver: inputMaskResolverMock
        )
        sut.view = viewMock

        viewMock.fullReset()
        validatorMock.fullReset()
        paymentSystemResolverMock.fullReset()
        bankResolverMock.fullReset()
        inputMaskResolverMock.fullReset()
        outputMock?.fullReset()
    }
}
