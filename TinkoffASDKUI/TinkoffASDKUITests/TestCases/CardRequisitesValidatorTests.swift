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
    private var paymentSystemResolverMock: PaymentSystemResolverMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        paymentSystemResolverMock = PaymentSystemResolverMock()
    }

    override func tearDown() {
        paymentSystemResolverMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_validate_cardNumber_success() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        paymentSystemResolverMock.resolveReturnValue = .resolved(.mir)
        // when
        let isValid = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_cardNumber_when_passed_various_numbers() throws {
        allureId(2559792, "При исправлении невалидного номера карты title становится серым")
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        let invalidCardNumber = "22013820000001045"
        paymentSystemResolverMock.resolveReturnValue = .resolved(.mir)
        // when
        let isValidFirst = sut.validate(inputPAN: invalidCardNumber)
        let isValidSecond = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertEqual(isValidFirst, false)
        XCTAssertEqual(isValidSecond, true)
    }

    func test_validate_cardNumber_failure() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputPAN: "2201382002500104")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_cardNumber_starts_with_zero_failure() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputPAN: "0001382002500104")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_cardNumber_unrecognized_payment_system_failure() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputPAN: "9999990000000000")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear_success() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(validThruYear: 29, month: 11)
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_validThruYear_failure() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(validThruYear: 29, month: 00)
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear_failure2() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(validThruYear: 29, month: 13)
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_inputCVC_success() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputCVC: "123")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_inputCVC_failure() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputCVC: "13")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_validate_validThruYear2_success() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputValidThru: "1129")
        // then
        XCTAssertEqual(isValid, true)
    }

    func test_validate_validThruYear2_failure() throws {
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValid = sut.validate(inputValidThru: "0029")
        // then
        XCTAssertEqual(isValid, false)
    }

    func test_valid_validThruYear_invalid_values() {
        allureId(2559746, "При вводе невалидного срока title становится красным")
        // given
        let sut: ICardRequisitesValidator = prepareSut()
        // when
        let isValidFirst = sut.validate(inputValidThru: "1333")
        let isValidSecond = sut.validate(inputValidThru: "0044")
        // then
        XCTAssertEqual([isValidFirst, isValidSecond], [false, false])
    }

    func test_validate_validThruYear_without_options_success() {
        // given
        let sut = prepareSut(options: [])
        // when
        let isValid = sut.validate(validThruYear: 24, month: 7)
        // then
        XCTAssertTrue(isValid)
    }

    func test_validate_validThruYear_without_options_failure() {
        // given
        let sut = prepareSut(options: [])
        // when
        let isValid = sut.validate(validThruYear: 22, month: 7)
        // then
        XCTAssertFalse(isValid)
    }

    func test_validate_inputThruYear_failure() {
        // given
        let sut = prepareSut()
        // when
        let isValid = sut.validate(inputValidThru: "22")
        // then
        XCTAssertFalse(isValid)
    }

    func test_validate_when_payment_system_is_visa() {
        // given
        let sut = prepareSut()
        paymentSystemResolverMock.resolveReturnValue = .resolved(.visa)
        // when
        let isValid = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertTrue(isValid)
    }

    func test_validate_when_payment_system_is_mastercard() {
        // given
        let sut = prepareSut()
        paymentSystemResolverMock.resolveReturnValue = .resolved(.masterCard)
        // when
        let isValid = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertTrue(isValid)
    }

    func test_validate_when_payment_system_is_unionpay() {
        // given
        let sut = prepareSut()
        paymentSystemResolverMock.resolveReturnValue = .resolved(.unionPay)
        // when
        let isValid = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertTrue(isValid)
    }

    func test_validate_when_payment_system_is_maestro() {
        // given
        let sut = prepareSut()
        paymentSystemResolverMock.resolveReturnValue = .resolved(.maestro)
        // when
        let isValid = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertTrue(isValid)
    }

    func test_validate_when_payment_system_is_ambiguous() {
        // given
        let sut = prepareSut()
        paymentSystemResolverMock.resolveReturnValue = .ambiguous
        // when
        let isValid = sut.validate(inputPAN: .validCard)
        // then
        XCTAssertTrue(isValid)
    }

    // MARK: Private

    private func prepareSut(options: CardRequisitesValidator.Options = [.disableExpiryDateValidation]) -> CardRequisitesValidator {
        let validator = CardRequisitesValidator(
            paymentSystemResolver: paymentSystemResolverMock,
            options: options
        )

        return validator
    }
}

private extension String {
    static let validCard = "2201382000000104"
}
