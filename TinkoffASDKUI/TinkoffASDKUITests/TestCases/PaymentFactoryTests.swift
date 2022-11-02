//
//  PaymentFactoryTests.swift
//  TinkoffASDKUI
//
//  Created by Ivan Glushko on 18.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class PaymentFactoryTests: XCTestCase {

    func testCreatePayment_when_PaymentSource_Unknown() throws {
        let dependencies = Self.makeDependencies()
        let sut = dependencies.sut
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let proccess = sut.createPayment(
            paymentSource: .unknown,
            paymentFlow: paymentFlow,
            paymentDelegate: dependencies.paymentDelegateMock
        )

        // then
        XCTAssertNil(proccess)
    }

    func testCreatePayment_when_PaymentSource_CardNumber() throws {

        let dependencies = Self.makeDependencies()
        let sut = dependencies.sut

        let paymentSourceData = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: dependencies.paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is CardPaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }

    func testCreatePayment_when_PaymentSource_SavedCard() throws {

        let dependencies = Self.makeDependencies()
        let sut = dependencies.sut

        let paymentSourceData = PaymentSourceData.savedCard(cardId: "4324234234", cvv: "232")
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: dependencies.paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is CardPaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }

    func testCreatePayment_when_PaymentSource_PaymentData() throws {

        let dependencies = Self.makeDependencies()
        let sut = dependencies.sut

        let paymentSourceData = PaymentSourceData.paymentData("234234")
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: dependencies.paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is CardPaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }

    func testCreatePayment_when_PaymentSource_ParentPayment() throws {

        let dependencies = Self.makeDependencies()
        let sut = dependencies.sut

        let paymentSourceData: PaymentSourceData = .parentPayment(rebuidId: "2423424")
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: dependencies.paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is ChargePaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }
}

extension PaymentFactoryTests {

    struct Dependecies {
        let paymentDelegateMock: MockPaymentProcessDelegate
        let ipProviderMock: MockIPAddressProvider
        let paymentsServiceMock: MockAcquiringPaymentsService
        let threeDsServiceMock: MockAcquiringThreeDsService
        let sut: PaymentFactory
    }

    static func makeDependencies() -> Dependecies {
        let ipProviderMock = MockIPAddressProvider()
        let paymentDelegateMock = MockPaymentProcessDelegate()
        let paymentsServiceMock = MockAcquiringPaymentsService()
        let threeDsServiceMock = MockAcquiringThreeDsService()

        let sut = PaymentFactory(
            paymentsService: paymentsServiceMock,
            threeDsService: threeDsServiceMock,
            ipProvider: ipProviderMock
        )

        return Dependecies(
            paymentDelegateMock: paymentDelegateMock,
            ipProviderMock: ipProviderMock,
            paymentsServiceMock: paymentsServiceMock,
            threeDsServiceMock: threeDsServiceMock,
            sut: sut
        )
    }
}
