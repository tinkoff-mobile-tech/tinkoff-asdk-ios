//
//  ChargePaymentProcessTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.10.2022.
//

import Foundation
@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class ChargePaymentProcessTests: XCTestCase {

    // MARK: - func start() when paymentFlow == .full

    func test_Start_when_paymentFlow_full_InitPayment_failure() {

        // given

        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentCompletionClosureInput = .failure(TestsError.basic)

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallsCount,
            1
        )

        // then

        XCTAssertEqual(dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount, 1)
    }

    func test_Start_when_paymentFlow_full_InitPayment_success_Charge_success() {

        let paymentStatus = AcquiringStatus.authorized

        let getPaymentStatePayload = GetPaymentStatePayload(
            paymentId: "2222",
            amount: 234,
            orderId: "32423423",
            status: paymentStatus
        )

        let initPayload = InitPayload(
            amount: 324,
            orderId: "324234",
            paymentId: "2222",
            status: paymentStatus
        )

        let chargePayload = ChargePayload(status: paymentStatus, paymentState: getPaymentStatePayload)

        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentCompletionClosureInput = .success(initPayload)
        dependencies.paymentsServiceMock.chargeCompletionClosureInput = .success(chargePayload)

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentsServiceMock.chargeCallsCount,
            1
        )

        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )
    }

    func test_Start_when_paymentFlow_full_InitPayment_success_Charge_failure() {

        let paymentStatus = AcquiringStatus.authorized

        let initPayload = InitPayload(
            amount: 324,
            orderId: "324234",
            paymentId: "2222",
            status: paymentStatus
        )

        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentCompletionClosureInput = .success(initPayload)
        dependencies.paymentsServiceMock.chargeCompletionClosureInput = .failure(TestsError.basic)

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallsCount,
            1
        )

        // then
        XCTAssertEqual(dependencies.paymentsServiceMock.chargeCallsCount, 1)
        XCTAssertEqual(dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount, 1)
    }

    // MARK: - func start() when paymentFlow == .finish

    func test_Start_paymentFlow_finish_Charge_success() {
        let customerOptions = CustomerOptions(customerKey: "somekey", email: "some")
        let options = FinishPaymentOptions(paymentId: "23423", amount: 100, orderId: "id", customerOptions: customerOptions)
        let dependencies = Self.makeDependencies(paymentFlow: .finish(paymentOptions: options))

        let paymentState = GetPaymentStatePayload(
            paymentId: "324234",
            amount: 234,
            orderId: "23423",
            status: .authorized
        )

        let chargePayload = ChargePayload(status: .authorized, paymentState: paymentState)

        dependencies.paymentsServiceMock.chargeCompletionClosureInput = .success(chargePayload)

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.chargeCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFinishWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_finish_Charge_failure() {
        let customerOptions = CustomerOptions(customerKey: "somekey", email: "some")
        let options = FinishPaymentOptions(paymentId: "23423", amount: 100, orderId: "id", customerOptions: customerOptions)
        let dependencies = Self.makeDependencies(paymentFlow: .finish(paymentOptions: options))

        dependencies.paymentsServiceMock.chargeCompletionClosureInput = .failure(TestsError.basic)

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.chargeCallsCount,
            1
        )
        XCTAssertEqual(
            dependencies.paymentDelegateMock.paymentDidFailedWithCallsCount,
            1
        )
    }

    func test_Start_paymentFlow_cancel_request() {
        // given
        let cancellableMock = CancellableMock()
        let dependencies = Self.makeDependencies(paymentFlow: .full(paymentOptions: .fake()))

        dependencies.paymentsServiceMock.initPaymentReturnValue = cancellableMock

        // when
        dependencies.sut.start()
        dependencies.sut.cancel()

        // then
        XCTAssertEqual(cancellableMock.cancelCallsCount, 1)
    }
}

extension ChargePaymentProcessTests {

    func start_when_paymentFlow_full(
        initPayloadResult: Result<InitPayload, Error>
    ) -> Dependencies {
        let paymentOptions = UIASDKTestsAssembly.makePaymentOptions()
        let dependencies = Self.makeDependencies(
            paymentFlow: .full(paymentOptions: paymentOptions)
        )

        dependencies.paymentsServiceMock.initPaymentCompletionClosureInput = initPayloadResult

        // when
        dependencies.sutAsProtocol.start()

        // then
        XCTAssertEqual(
            dependencies.paymentsServiceMock.initPaymentCallsCount,
            1
        )

        return dependencies
    }
}

// MARK: - Dependencies

extension ChargePaymentProcessTests {

    struct Dependencies {
        let sut: ChargePaymentProcess
        let sutAsProtocol: IPaymentProcess
        let paymentDelegateMock: PaymentProcessDelegateMock
        let paymentsServiceMock: AcquiringPaymentsServiceMock
        let paymentSource: PaymentSourceData
    }

    static func makeDependencies(paymentFlow: PaymentFlow) -> Dependencies {
        let paymentDelegateMock = PaymentProcessDelegateMock()
        let paymentsServiceMock = AcquiringPaymentsServiceMock()
        let paymentSource = UIASDKTestsAssembly.makePaymentSourceData_parentPayment()

        let sut = ChargePaymentProcess(
            paymentsService: paymentsServiceMock,
            paymentSource: paymentSource,
            paymentFlow: paymentFlow,
            delegate: paymentDelegateMock
        )

        return Dependencies(
            sut: sut,
            sutAsProtocol: sut,
            paymentDelegateMock: paymentDelegateMock,
            paymentsServiceMock: paymentsServiceMock,
            paymentSource: paymentSource
        )
    }
}
