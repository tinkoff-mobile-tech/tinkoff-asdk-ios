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

    func test_didFillCardNumber_calls() throws {
        // given
        let dependencies = buildDependencies()
        // when
        dependencies.sutAsProtocol.didFillCardNumber(text: "42343432452344", filled: true)
        // then

        XCTAssertEqual(dependencies.bankSystemResolverMock.resolveCallCounter, 1)
        XCTAssertEqual(dependencies.paymentSystemResolverMock.resolveCallCounter, 1)
        XCTAssertEqual(dependencies.viewMock.activateExpirationFieldCallCounter, 1)
    }

    func test_didFillExpiration_calls() throws {
        // given
        let dependencies = buildDependencies()
        // when
        dependencies.sutAsProtocol.didFillExpiration(text: "1139", filled: true)
        // then
        XCTAssertEqual(dependencies.viewMock.activateCvcFieldCallCounter, 1)
    }

    func test_didFillCvc_calls() throws {
        // given
        let dependencies = buildDependencies()
        // when
        dependencies.sutAsProtocol.didFillCvc(text: "123", filled: true)
        // then
        XCTAssertEqual(dependencies.viewMock.deactivateCallCounter, 1)
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

    func buildDependencies() -> Dependencies {
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

        return Dependencies(
            sut: presenter,
            viewMock: viewMock,
            validatorMock: validatorMock,
            paymentSystemResolverMock: paymentSystemResolverMock,
            bankSystemResolverMock: bankSystemResolverMock
        )
    }
}
