//
//  PaymentStatusUpdateServiceTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 06.06.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class TestsPaymentStatusUpdateServiceTests: BaseTestCase {

    var sut: PaymentStatusUpdateService!

    // Mocks

    var acquiringPaymentsServiceMock: AcquiringPaymentsServiceMock!
    var paymentStatusUpdateServiceDelegateMock: PaymentStatusUpdateServiceDelegateMock!
    var repeatedRequestHelperMock: RepeatedRequestHelperMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        acquiringPaymentsServiceMock = AcquiringPaymentsServiceMock()
        paymentStatusUpdateServiceDelegateMock = PaymentStatusUpdateServiceDelegateMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()

        let paymentStatusService = PaymentStatusService(paymentService: acquiringPaymentsServiceMock)
        let repeatedRequestHelper = RepeatedRequestHelper(delay: 3)

        sut = PaymentStatusUpdateService(
            paymentStatusService: paymentStatusService,
            repeatedRequestHelper: repeatedRequestHelper,
            maxRequestRepeatCount: 10
        )
        sut.delegate = paymentStatusUpdateServiceDelegateMock
    }

    override func tearDown() {
        acquiringPaymentsServiceMock = nil
        paymentStatusUpdateServiceDelegateMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_getPaymentState() {

        acquiringPaymentsServiceMock.getPaymentStateCompletionClosureInput = .success(.fake(status: .unknown))

        let data = FullPaymentData(
            paymentProcess: PaymentProcessMock(),
            payload: .fake(status: .unknown),
            cardId: "",
            rebillId: ""
        )

        let expt = expectation(description: #function)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        wait(for: [expt], timeout: 100)
        // then
    }
}
