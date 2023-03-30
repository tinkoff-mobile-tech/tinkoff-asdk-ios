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

    // Dependencies

    var paymentDelegateMock: MockPaymentProcessDelegate!
    var ipProviderMock: MockIPAddressProvider!
    var paymentsServiceMock: MockAcquiringPaymentsService!
    var threeDsServiceMock: MockAcquiringThreeDsService!
    var threeDSDeviceInfoProviderMock: ThreeDSDeviceInfoProviderMock!
    var sut: PaymentFactory!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        let ipProviderMock = MockIPAddressProvider()
        let paymentDelegateMock = MockPaymentProcessDelegate()
        let paymentsServiceMock = MockAcquiringPaymentsService()
        let threeDsServiceMock = MockAcquiringThreeDsService()
        let threeDSDeviceInfoProviderMock = ThreeDSDeviceInfoProviderMock()

        let sut = PaymentFactory(
            paymentsService: paymentsServiceMock,
            threeDsService: threeDsServiceMock,
            threeDSDeviceInfoProvider: threeDSDeviceInfoProviderMock,
            ipProvider: ipProviderMock
        )

        self.paymentDelegateMock = paymentDelegateMock
        self.ipProviderMock = ipProviderMock
        self.paymentsServiceMock = paymentsServiceMock
        self.threeDsServiceMock = threeDsServiceMock
        self.threeDSDeviceInfoProviderMock = threeDSDeviceInfoProviderMock
        self.sut = sut
    }

    override func tearDown() {
        paymentDelegateMock = nil
        ipProviderMock = nil
        paymentsServiceMock = nil
        threeDsServiceMock = nil
        threeDSDeviceInfoProviderMock = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testCreatePayment_withYandexPayFullFlow_shouldReturnYandexPayPaymentProcess() throws {
        // given
        let options = PaymentOptions(orderOptions: OrderOptions(orderId: "id", amount: 100))

        // when
        let process = sut.createPayment(
            paymentSource: .yandexPay(base64Token: "some token"),
            paymentFlow: .full(paymentOptions: options),
            paymentDelegate: paymentDelegateMock
        )

        // then
        XCTAssert(process is YandexPayPaymentProcess)
    }

    func testCreatePayment_withYandexPayFinishFlow_shouldReturnYandexPayPaymentProcess() throws {
        // given
        let options = FinishPaymentOptions(paymentId: "fdfd", amount: 100, orderId: "id", customerOptions: nil)

        // when
        let proccess = sut.createPayment(
            paymentSource: .yandexPay(base64Token: "some token"),
            paymentFlow: .finish(paymentOptions: options),
            paymentDelegate: paymentDelegateMock
        )

        // then
        XCTAssertNotNil(proccess is YandexPayPaymentProcess)
    }

    func testCreatePayment_when_PaymentSource_CardNumber() throws {
        let paymentSourceData = UIASDKTestsAssembly.makePaymentSourceData_cardNumber()
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is CardPaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }

    func testCreatePayment_when_PaymentSource_SavedCard() throws {
        // given
        let paymentSourceData = PaymentSourceData.savedCard(cardId: "4324234234", cvv: "232")
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is CardPaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }

    func testCreatePayment_when_PaymentSource_ParentPayment() throws {
        // given
        let paymentSourceData: PaymentSourceData = .parentPayment(rebuidId: "2423424")
        let paymentFlow: PaymentFlow = .full(paymentOptions: UIASDKTestsAssembly.makePaymentOptions())

        // when
        let paymentProcess = sut.createPayment(
            paymentSource: paymentSourceData,
            paymentFlow: paymentFlow,
            paymentDelegate: paymentDelegateMock
        )

        // then
        XCTAssertTrue(paymentProcess is ChargePaymentProcess)
        XCTAssertEqual(paymentProcess?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentProcess?.paymentSource, paymentSourceData)
    }
}
