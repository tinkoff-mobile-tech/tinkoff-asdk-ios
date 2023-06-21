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

final class CardRequisitesValidatorTests: BaseTestCase {

    // Dependencies
    var sutAsProtocol: ICardRequisitesValidator { sut }
    var sut: CardRequisitesValidator!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let validator = CardRequisitesValidator(
            paymentSystemResolver: PaymentSystemResolver(),
            options: .disableExpiryDateValidation
        )

        sut = validator
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_validate_cardNumber_success() throws {
        // when
        let isValid = sutAsProtocol.validate(inputPAN: .validCard)
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_cardNumber_when_passed_various_numbers() throws {
        allureId(2559792, "При исправлении невалидного номера карты title становится серым")
        // given
        let invalidCardNumber = "22013820000001045"
        // when
        let isValidFirst = sutAsProtocol.validate(inputPAN: invalidCardNumber)
        let isValidSecond = sutAsProtocol.validate(inputPAN: .validCard)
        // then
        XCTAssertEqual(isValidFirst, false)
        XCTAssertEqual(isValidSecond, true)
    }

    func test_validate_cardNumber_failure() throws {
        // when
        let isValid = sutAsProtocol.validate(inputPAN: "2201382002500104")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_cardNumber_starts_with_zero_failure() throws {
        // when
        let isValid = sutAsProtocol.validate(inputPAN: "0001382002500104")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_cardNumber_unrecognized_payment_system_failure() throws {
        // when
        let isValid = sutAsProtocol.validate(inputPAN: "9999990000000000")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear_success() throws {
        // when
        let isValid = sutAsProtocol.validate(validThruYear: 29, month: 11)
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_validThruYear_failure() throws {
        // when
        let isValid = sutAsProtocol.validate(validThruYear: 29, month: 00)
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear_failure2() throws {
        // when
        let isValid = sutAsProtocol.validate(validThruYear: 29, month: 13)
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_inputCVC_success() throws {
        // when
        let isValid = sutAsProtocol.validate(inputCVC: "123")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_inputCVC_failure() throws {
        // when
        let isValid = sutAsProtocol.validate(inputCVC: "13")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear2_success() throws {
        // when
        let isValid = sutAsProtocol.validate(inputValidThru: "1129")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_validThruYear2_failure() throws {
        // when
        let isValid = sutAsProtocol.validate(inputValidThru: "0029")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_valid_validThruYear_invalid_values() {
        allureId(2559746, "При вводе невалидного срока title становится красным")

        // when
        let isValidFirst = sutAsProtocol.validate(inputValidThru: "1333")
        let isValidSecond = sutAsProtocol.validate(inputValidThru: "0044")
        // then
        XCTAssertEqual([isValidFirst, isValidSecond], [false, false])
    }
}

private extension String {
    static let validCard = "2201382000000104"
}
