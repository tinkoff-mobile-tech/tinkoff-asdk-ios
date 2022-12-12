//
//  CardRequisitesValidatorTests.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 30.11.2022.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

import Foundation
import XCTest

final class CardRequisitesValidatorTests: XCTestCase {

    func test_validate_cardNumber_success() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(inputPAN: "2201382000000104")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_cardNumber_failure() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(inputPAN: "2201382002500104")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear_success() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(validThruYear: 29, month: 11)
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_validThruYear_failure() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(validThruYear: 29, month: 00)
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_inputCVC_success() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(inputCVC: "123")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_inputCVC_failure() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(inputCVC: "13")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear2_success() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(inputValidThru: "1129")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_validThruYear2_failure() throws {
        // given
        let dependencies = buildDependencies()
        // when
        let isValid = dependencies.sutAsProtocol.validate(inputValidThru: "0029")
        // then
        XCTAssertEqual(isValid, false)
    }
}

extension CardRequisitesValidatorTests {

    struct Dependencies {
        var sutAsProtocol: ICardRequisitesValidator { sut }
        let sut: CardRequisitesValidator
        let paymentSystemResolverMock: MockPaymentSystemResolver
    }

    func buildDependencies() -> Dependencies {
        let paymentSystemResolverMock = MockPaymentSystemResolver()

        let validator = CardRequisitesValidator(
            paymentSystemResolver: paymentSystemResolverMock,
            options: .disableExpiryDateValidation
        )

        return Dependencies(
            sut: validator,
            paymentSystemResolverMock: paymentSystemResolverMock
        )
    }
}
