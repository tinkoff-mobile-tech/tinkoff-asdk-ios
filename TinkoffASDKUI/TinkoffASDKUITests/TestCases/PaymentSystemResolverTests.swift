//
//  PaymentSystemResolverTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 25.05.2023.
//

import Foundation
@testable import TinkoffASDKUI
import XCTest

final class PaymentSystemResolverTests: BaseTestCase {
    // Dependencies

    var sut: PaymentSystemResolver!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        sut = PaymentSystemResolver()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_resolvePaymentSystem_whenBinIsEqualToMir() throws {
        allureId(2419460, "PaymentSystemResolver определяет BIN для Мир")
        try test_resolvePaymentSystem(by: .mir, expected: .mir)
    }

    func test_resolvePaymentSystemByBin_whenBinIsEqualToVisa() throws {
        allureId(2419456, "PaymentSystemResolver определяет BIN для Visa")
        try test_resolvePaymentSystem(by: .visa, expected: .visa)
    }

    func test_resolvePaymentSystemByBin_whenBinIsEqualToMastercard() throws {
        allureId(2419457, "PaymentSystemResolver определяет BIN для Mastercard")
        try test_resolvePaymentSystem(by: .masterCard, expected: .masterCard)
    }

    func test_resolvePaymentSystemByBin_whenBinIsEqualToUnion() throws {
        allureId(2419458, "PaymentSystemResolver определяет BIN для UnionPay")
        try test_resolvePaymentSystem(by: .unionPay, expected: .unionPay)
    }

    func test_resolvePaymentSystemByBin_whenBinIsEqualToMaestro() throws {
        allureId(2419459, "PaymentSystemResolver определяет BIN для Maestro")
        try test_resolvePaymentSystem(by: .maestro, expected: .maestro)
    }

    func test_notResolvePaymentSystemByBin_whenBinIsLessThanSixNumbers() {
        allureId(2429789, "PaymentSystemResolver возвращает неизвестную платежную систему для BIN < 6 символов")

        // when
        let paymentSystemDecision = sut.resolve(by: .invalidBin)

        // then
        if case .unrecognized = paymentSystemDecision {}
        else { XCTFail("PaymentSystemDecision must be equal to unrecognized") }
    }

    func test_notResolvePaymentSystemByBin_whenBinIsEmpty() {
        allureId(2429791, "PaymentSystemResolver возвращает неизвестную платежную систему для BIN = \"\" (пустой строке)")

        // when
        let paymentSystemDecision = sut.resolve(by: .empty)

        // then
        if case .unrecognized = paymentSystemDecision {}
        else { XCTFail("PaymentSystemDecision must be equal to unrecognized") }
    }

    func test_notResolvePaymentSystemByBin_whenBinIsUnknown() {
        allureId(2429790, "PaymentSystemResolver возвращает неизвестный тип оплаты для неизвестного BIN")

        // when
        let paymentSystemDecision = sut.resolve(by: .americanExpress)

        // then
        if case .unrecognized = paymentSystemDecision {}
        else { XCTFail("PaymentSystemDecision must be equal to unrecognized") }
    }

    // MARK: - Private

    private func test_resolvePaymentSystem(by bin: String, expected: PaymentSystem) throws {
        // when
        let paymentSystemDecision = sut.resolve(by: bin)

        // then
        let paymentSystem = try XCTUnwrap(paymentSystemDecision.getPaymentSystem())
        XCTAssertEqual(paymentSystem, expected)
    }
}

// MARK: Constants

private extension String {
    static let empty = ""

    static let invalidBin = "11111"

    static let maestro = "6759649826438453"
    static let unionPay = "6210946888090005"
    static let masterCard = "5555555555554444"
    static let visa = "4000060000000006"
    static let mir = "22001234556789010"
    static let americanExpress = "378282246310005"
}
