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
    var paymentSystemResolverMock: PaymentSystemResolverMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let paymentSystemResolverMock = PaymentSystemResolverMock()
        let validator = CardRequisitesValidator(
            paymentSystemResolver: paymentSystemResolverMock,
            options: .disableExpiryDateValidation
        )

        sut = validator
        self.paymentSystemResolverMock = paymentSystemResolverMock
    }

    override func tearDown() {
        sut = nil
        paymentSystemResolverMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_validate_cardNumber_success() throws {
        // when
        let isValid = sutAsProtocol.validate(inputPAN: "2201382000000104")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_cardNumber_when_passed_various_numbers() throws {
        allureId(2559792, "При исправлении невалидного номера карты title становится серым")
        // given
        let invalidCardNumber = "2201382000000105"
        let validCardNumber = "2201382000000104"
        // when
        let isValidFirst = sutAsProtocol.validate(inputPAN: invalidCardNumber)
        let isValidSecond = sutAsProtocol.validate(inputPAN: validCardNumber)
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
}
