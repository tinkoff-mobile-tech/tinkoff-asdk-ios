//
//  PaymentSystemTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 13.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class PaymentSystemTests: XCTestCase {
    func test_thatPaymentSystemHasCorrectImage_whenPaymentSystemIsMir() {
        // when
        let image = PaymentSystem.mir.icon

        // then
        XCTAssertEqual(image, DynamicIconCardView.Icon.PaymentSystem.mir)
    }

    func test_thatPaymentSystemHasCorrectImage_whenPaymentSystemIsMasterCard() {
        // when
        let image = PaymentSystem.masterCard.icon

        // then
        XCTAssertEqual(image, DynamicIconCardView.Icon.PaymentSystem.masterCard)
    }

    func test_thatPaymentSystemHasCorrectImage_whenPaymentSystemIsVisa() {
        // when
        let image = PaymentSystem.visa.icon

        // then
        XCTAssertEqual(image, DynamicIconCardView.Icon.PaymentSystem.visa)
    }

    func test_thatPaymentSystemHasCorrectImage_whenPaymentSystemIsMaestro() {
        // when
        let image = PaymentSystem.maestro.icon

        // then
        XCTAssertEqual(image, DynamicIconCardView.Icon.PaymentSystem.maestro)
    }

    func test_thatPaymentSystemHasCorrectImage_whenPaymentSystemIsUnionPay() {
        // when
        let image = PaymentSystem.unionPay.icon

        // then
        XCTAssertEqual(image, DynamicIconCardView.Icon.PaymentSystem.uninonPay)
    }
}
