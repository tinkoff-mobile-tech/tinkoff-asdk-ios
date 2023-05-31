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
    var inputMaskResolver: CardRequisitesMasksResolverMock!
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
        inputMaskResolver = nil
        outputMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

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
    private func setupSut(isScanButtonNeeded: Bool = false) {
        viewMock = CardFieldViewInputMock()
        validatorMock = CardRequisitesValidatorMock()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        bankResolverMock = BankResolverMock()
        inputMaskResolver = CardRequisitesMasksResolverMock()
        outputMock = CardFieldOutputMock()

        sut = CardFieldPresenter(
            output: outputMock,
            isScanButtonNeeded: isScanButtonNeeded,
            validator: validatorMock,
            paymentSystemResolver: paymentSystemResolverMock,
            bankResolver: bankResolverMock,
            inputMaskResolver: inputMaskResolver
        )
        sut.view = viewMock

        viewMock.fullReset()
        validatorMock.fullReset()
        paymentSystemResolverMock.fullReset()
        bankResolverMock.fullReset()
        inputMaskResolver.fullReset()
        outputMock.fullReset()
    }
}
