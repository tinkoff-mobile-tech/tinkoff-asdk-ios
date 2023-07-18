//
//  PaymentSystemImageResolverTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 12.07.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class PaymentSystemImageResolverTests: XCTestCase {

    // MARK: Properties

    private var sut: PaymentSystemImageResolver!
    private var paymentSystemResolverMock: PaymentSystemResolverMock!

    // MARK: Initialization

    override func setUp() {
        super.setUp()
        paymentSystemResolverMock = PaymentSystemResolverMock()
        sut = PaymentSystemImageResolver(paymentSystemResolver: paymentSystemResolverMock)
    }

    override func tearDown() {
        sut = nil
        paymentSystemResolverMock = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsVisa() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .resolved(.visa)

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertEqual(image, Asset.CardRequisites.visaLogo.image)
    }

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsMasterCard() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .resolved(.masterCard)

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertEqual(image, Asset.CardRequisites.mcLogo.image)
    }

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsMaestro() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .resolved(.maestro)

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertEqual(image, Asset.CardRequisites.maestroLogo.image)
    }

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsUnionPay() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .resolved(.unionPay)

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertEqual(image, Asset.PaymentCard.PaymentSystem.unionpay.image)
    }

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsMir() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .resolved(.mir)

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertEqual(image, Asset.CardRequisites.mirLogo.image)
    }

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsAmbiguous() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .ambiguous

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertNil(image)
    }

    func test_thatResolverResolvesPaymentSystem_whenPaymentSystemIsUnrecognized() {
        // given
        paymentSystemResolverMock.resolveReturnValue = .unrecognized

        // when
        let image = sut.resolve(by: nil)

        // then
        XCTAssertNil(image)
    }
}
