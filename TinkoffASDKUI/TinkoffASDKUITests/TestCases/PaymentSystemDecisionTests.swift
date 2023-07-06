//
//  PaymentSystemDecisionTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 06.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class PaymentSystemDecisionTests: XCTestCase {
    func test_thatPaymentSystemsAreEqual_whenResolved() {
        // given
        let paymentSystem1 = PaymentSystemDecision.resolved(.masterCard)
        let paymentSystem2 = PaymentSystemDecision.resolved(.masterCard)

        // then
        XCTAssertEqual(paymentSystem1, paymentSystem2)
    }

    func test_thatPaymentSystemsAreNotEqual_whenResolved() {
        // given
        let paymentSystem1 = PaymentSystemDecision.resolved(.masterCard)
        let paymentSystem2 = PaymentSystemDecision.resolved(.visa)

        // then
        XCTAssertNotEqual(paymentSystem1, paymentSystem2)
    }

    func test_thatPaymentSystemsAreEqual_whenAmbiguous() {
        // given
        let paymentSystem1 = PaymentSystemDecision.ambiguous
        let paymentSystem2 = PaymentSystemDecision.ambiguous

        // then
        XCTAssertEqual(paymentSystem1, paymentSystem2)
    }

    func test_thatPaymentSystemsAreNotEqual_whenAmbiguous() {
        // given
        let paymentSystem1 = PaymentSystemDecision.resolved(.visa)
        let paymentSystem2 = PaymentSystemDecision.ambiguous

        // then
        XCTAssertNotEqual(paymentSystem1, paymentSystem2)
    }

    func test_thatPaymentSystemsAreEqual_whenUnrecognized() {
        // given
        let paymentSystem1 = PaymentSystemDecision.unrecognized
        let paymentSystem2 = PaymentSystemDecision.unrecognized

        // then
        XCTAssertEqual(paymentSystem1, paymentSystem2)
    }

    func test_thatPaymentSystemsAreNotEqual_whenUnrecognized() {
        // given
        let paymentSystem1 = PaymentSystemDecision.resolved(.visa)
        let paymentSystem2 = PaymentSystemDecision.unrecognized

        // then
        XCTAssertNotEqual(paymentSystem1, paymentSystem2)
    }

    func test_thatPaymentSystemIsNil_whenUnrecognized() {
        //
        let paymentSystem = PaymentSystemDecision.unrecognized

        // then
        XCTAssertNil(paymentSystem.getPaymentSystem())
    }

    func test_thatPaymentSystemIsNil_whenAmbiguous() {
        //
        let paymentSystem = PaymentSystemDecision.ambiguous

        // then
        XCTAssertNil(paymentSystem.getPaymentSystem())
    }
}
