//
//  CardFieldPresenterTests.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation
import XCTest

final class CardFieldPresenterTests: XCTestCase {

    // Dependencies
    var sutAsProtocol: ICardFieldPresenter { sut }

    var sut: CardFieldPresenter!
    var viewMock: MockCardFieldView!
    var validatorMock: MockCardRequisitesValidator!
    var paymentSystemResolverMock: MockPaymentSystemResolver!
    var bankSystemResolverMock: MockBankResolver!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let viewMock = MockCardFieldView()
        let validatorMock = MockCardRequisitesValidator()
        let paymentSystemResolverMock = MockPaymentSystemResolver()
        let bankSystemResolverMock = MockBankResolver()

        let presenter = CardFieldPresenter(
            getCardFieldView: { viewMock },
            listenerStorage: [],
            config: assembleConfig(),
            validator: validatorMock,
            paymentSystemResolver: paymentSystemResolverMock,
            bankResolver: bankSystemResolverMock
        )

        sut = presenter
        self.viewMock = viewMock
        self.validatorMock = validatorMock
        self.paymentSystemResolverMock = paymentSystemResolverMock
        self.bankSystemResolverMock = bankSystemResolverMock
    }

    override func tearDown() {
        sut = nil
        viewMock = nil
        validatorMock = nil
        paymentSystemResolverMock = nil
        bankSystemResolverMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_didFillCardNumber_calls() throws {
        // when
        sutAsProtocol.didFillCardNumber(text: "42343432452344", filled: true)
        // then

        XCTAssertEqual(bankSystemResolverMock.resolveCallCounter, 1)
        XCTAssertEqual(paymentSystemResolverMock.resolveCallCounter, 1)
        XCTAssertEqual(viewMock.activateExpirationFieldCallCounter, 1)
    }

    func test_didFillExpiration_calls() throws {
        // when
        sutAsProtocol.didFillExpiration(text: "1139", filled: true)
        // then
        XCTAssertEqual(viewMock.activateCvcFieldCallCounter, 1)
    }

    func test_didFillCvc_calls() throws {
        // when
        sutAsProtocol.didFillCvc(text: "123", filled: true)
        // then
        XCTAssertEqual(viewMock.deactivateCallCounter, 1)
    }

    func test_validateWholeForm_initialState() throws {
        // when
        let validationResult = sutAsProtocol.validateWholeForm()
        // then
        XCTAssertEqual(validationResult.isValid, false)
    }
}

extension CardFieldPresenterTests {

    struct Dependencies {
        let sut: CardFieldPresenter
        var sutAsProtocol: ICardFieldPresenter { sut }

        var viewMock: MockCardFieldView
        var validatorMock: MockCardRequisitesValidator
        var paymentSystemResolverMock: MockPaymentSystemResolver
        var bankSystemResolverMock: MockBankResolver
    }

    func assembleConfig() -> CardFieldView.Config {
        let textFieldData = CardFieldView.DataDependecies.TextFieldData(
            delegate: nil,
            text: nil,
            placeholder: nil,
            headerText: ""
        )

        return .assembleWithRegularStyle(
            data: CardFieldView.DataDependecies(
                dynamicCardIconData: DynamicIconCardView.Data(),
                expirationTextFieldData: textFieldData,
                cardNumberTextFieldData: textFieldData,
                cvcTextFieldData: textFieldData
            )
        )
    }
}
