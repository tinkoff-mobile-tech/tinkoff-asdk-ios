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

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil

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
        setupSut(customerEmail: validEmail)
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
        setupSut(customerEmail: email)
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
        setupSut(customerEmail: email)

        // when
        let isValidEmail = sut.isEmailValid

        // then
        XCTAssertTrue(isValidEmail)
    }

    func test_isEmailValid_when_false() {
        // given
        let email = "some123some.some"
        setupSut(customerEmail: email)

        // when
        let isValidEmail = sut.isEmailValid

        // then
        XCTAssertFalse(isValidEmail)
    }
}

// MARK: - Private methods

extension EmailViewPresenterTests {
    private func setupSut(customerEmail: String = "") {
        viewMock = EmailViewInputMock()
        outputMock = EmailViewPresenterOutputMock()
        sut = EmailViewPresenter(customerEmail: customerEmail, output: outputMock)
        sut.view = viewMock

        viewMock.fullReset()
    }
}
