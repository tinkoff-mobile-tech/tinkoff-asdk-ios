//
//  EmailViewPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 30.05.2023.
//

import Foundation
import UIKit
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class EmailViewPresenterTests: BaseTestCase {

    var sut: EmailViewPresenter!

    // MARK: Mocks

    var viewMock: EmailViewInputMock!
    var outputMock: EmailViewPresenterOutputMock!
    var emailValidatorMock: EmailValidatorMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        outputMock = nil
        emailValidatorMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_textFieldDidBeginEditing() {
        // when
        sut.textFieldDidBeginEditing()

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 1)
        XCTAssertEqual(outputMock.emailTextFieldDidBeginEditingCallsCount, 1)
    }

    func test_textFieldDidChangeText_to_newValue_valid() {
        // given
        let text = "some@some.some"
        emailValidatorMock.isValidReturnValue = true

        // when
        sut.textFieldDidChangeText(to: text)

        // then
        XCTAssertEqual(outputMock.emailTextFieldCallsCount, 1)
        XCTAssertEqual(outputMock.emailTextFieldReceivedArguments?.email, text)
        XCTAssertEqual(outputMock.emailTextFieldReceivedArguments?.isValid, true)
    }

    func test_textFieldDidChangeText_to_newValue_notValid() {
        // given
        let text = "some123some.some"
        emailValidatorMock.isValidReturnValue = false

        // when
        sut.textFieldDidChangeText(to: text)

        // then
        XCTAssertEqual(outputMock.emailTextFieldCallsCount, 1)
        XCTAssertEqual(outputMock.emailTextFieldReceivedArguments?.email, text)
        XCTAssertEqual(outputMock.emailTextFieldReceivedArguments?.isValid, false)
    }

    func test_textFieldDidChangeText_to_oldValue() {
        // given
        let text = ""

        // when
        sut.textFieldDidChangeText(to: text)

        // then
        XCTAssertEqual(outputMock.emailTextFieldCallsCount, 0)
    }

    func test_textFieldDidEndEditing_when_isFieldDidBeginEditingFalse() {
        // when
        sut.textFieldDidEndEditing()

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 0)
        XCTAssertEqual(outputMock.emailTextFieldDidEndEditingCallsCount, 1)
    }

    func test_textFieldDidEndEditing_when_isFieldDidBeginEditingTrue_emailValid() {
        // given
        let validEmail = "some@some.some"
        setupSut(customerEmail: validEmail)
        sut.textFieldDidBeginEditing()
        viewMock.fullReset()

        // when
        sut.textFieldDidEndEditing()

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 0)
        XCTAssertEqual(outputMock.emailTextFieldDidEndEditingCallsCount, 1)
    }

    func test_textFieldDidEndEditing_when_isFieldDidBeginEditingTrue_emailNotValid() {
        // given
        let validEmail = "some123some.some"
        setupSut(
            customerEmail: validEmail,
            beforeViewSetup: { [weak self] in self?.emailValidatorMock.isValidReturnValue = false }
        )
        sut.textFieldDidBeginEditing()
        viewMock.fullReset()

        // when
        sut.textFieldDidEndEditing()

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 0)
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 1)
        XCTAssertEqual(outputMock.emailTextFieldDidEndEditingCallsCount, 1)
    }

    func test_textFieldDidPressReturn() {
        // when
        sut.textFieldDidPressReturn()

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(outputMock.emailTextFieldDidPressReturnCallsCount, 1)
    }

    func test_setupView_when_emailValid_andEditingBegin() {
        // given
        let validEmail = "some@some.some"
        setupSut(customerEmail: validEmail)
        sut.textFieldDidBeginEditing()
        viewMock.fullReset()

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 0)
        XCTAssertEqual(viewMock.setTextFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldReceivedArguments?.text, validEmail)
        XCTAssertEqual(viewMock.setTextFieldReceivedArguments?.animated, false)
    }

    func test_setupView_when_emailNotValid_andEditingBegin() {
        // given
        let email = "some123some.some"
        setupSut(
            customerEmail: email,
            beforeViewSetup: { [weak self] in self?.emailValidatorMock.isValidReturnValue = false }
        )
        sut.textFieldDidBeginEditing()
        viewMock.fullReset()

        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 0)
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldReceivedArguments?.text, email)
        XCTAssertEqual(viewMock.setTextFieldReceivedArguments?.animated, false)
    }

    func test_setupView_when_editingNotBegin() {
        // when
        sut.view = viewMock

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderNormalCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 0)
        XCTAssertEqual(viewMock.setTextFieldCallsCount, 1)
        XCTAssertEqual(viewMock.setTextFieldReceivedArguments?.text, "")
        XCTAssertEqual(viewMock.setTextFieldReceivedArguments?.animated, false)
    }

    func test_isEmailValid_when_true() {
        // given
        let email = "some@some.some"
        setupSut(
            customerEmail: email,
            beforeViewSetup: { [weak self] in self?.emailValidatorMock.isValidReturnValue = true }
        )

        // when
        let isValidEmail = sut.isEmailValid

        // then
        XCTAssertTrue(isValidEmail)
    }

    func test_isEmailValid_when_false() {
        // given
        let email = "some123some.some"
        setupSut(
            customerEmail: email,
            beforeViewSetup: { [weak self] in self?.emailValidatorMock.isValidReturnValue = false }
        )

        // when
        let isValidEmail = sut.isEmailValid

        // then
        XCTAssertFalse(isValidEmail)
    }

    func test_setsHeaderError_for_invalid_filled_email() {
        // given
        let email = "EMAIL"

        // when
        setupSut(
            customerEmail: email,
            resetViewMock: false,
            beforeViewSetup: { [weak self] in self?.emailValidatorMock.isValidReturnValue = false }
        )

        // then
        XCTAssertEqual(viewMock.setTextFieldHeaderErrorCallsCount, 1)
    }
}

// MARK: - Private methods

extension EmailViewPresenterTests {
    private func setupSut(
        customerEmail: String = "",
        resetViewMock: Bool = true,
        beforeViewSetup: (() -> Void)? = nil
    ) {
        viewMock = EmailViewInputMock()
        outputMock = EmailViewPresenterOutputMock()
        emailValidatorMock = EmailValidatorMock()
        sut = EmailViewPresenter(customerEmail: customerEmail, output: outputMock, emailValidator: emailValidatorMock)
        beforeViewSetup?()
        sut.view = viewMock

        if resetViewMock { viewMock.fullReset() }
    }
}
