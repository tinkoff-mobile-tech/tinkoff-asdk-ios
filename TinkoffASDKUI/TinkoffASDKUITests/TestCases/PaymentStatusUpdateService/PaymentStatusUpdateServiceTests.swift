//
//  PaymentStatusUpdateServiceTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 20.06.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class PaymentStatusUpdateServiceTests: BaseTestCase {

    var sut: PaymentStatusUpdateService!

    // MARK: Mocks

    var paymentStatusServiceMock: PaymentStatusServiceMock!
    var repeatedRequestHelperMock: RepeatedRequestHelperMock!
    var paymentStatusUpdateServiceDelegateMock: PaymentStatusUpdateServiceDelegateMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        paymentStatusServiceMock = nil
        repeatedRequestHelperMock = nil
        paymentStatusUpdateServiceDelegateMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_startUpdateStatusIfNeeded_with_status_cancelled() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let payload = GetPaymentStatePayload.fake(status: .cancelled)
        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: payload, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentCancelStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_status_rejected() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let payload = GetPaymentStatePayload.fake(status: .rejected)
        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: payload, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFailureStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_status_deadlineExpired() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let payload = GetPaymentStatePayload.fake(status: .deadlineExpired)
        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: payload, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFailureStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_status_anySuccess() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let payload = GetPaymentStatePayload.fake(status: .confirmed)
        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: payload, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFinalStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_status_anyFailure() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let payload = GetPaymentStatePayload.fake(status: .attemptsExpired)
        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: payload, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFailureStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_notDefinedStatus_both_success() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let first = GetPaymentStatePayload.fake(status: .new)
        let second = GetPaymentStatePayload.fake(status: .confirmed)

        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(first), .success(second)]

        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: first, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, data.payload.paymentId)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFinalStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_notDefinedStatus_haveNoRepeatCount() {
        // given
        setupSut(maxRequestRepeatCount: 1)

        let first = GetPaymentStatePayload.fake(status: .new)
        let second = GetPaymentStatePayload.fake(status: .confirmed)

        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(first), .success(second)]

        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: first, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, data.payload.paymentId)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFinalStatusRecievedCallsCount, 0)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFailureStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_notDefinedStatus_failure_second() {
        // given
        setupSut(maxRequestRepeatCount: 2)

        let first = GetPaymentStatePayload.fake(status: .new)
        let error = NSError(domain: "error", code: 123456)

        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(first), .failure(error)]

        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: first, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, data.payload.paymentId)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFinalStatusRecievedCallsCount, 0)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFailureStatusRecievedCallsCount, 1)
    }

    func test_startUpdateStatusIfNeeded_with_notDefinedStatus_continues_failure() {
        // given
        setupSut(maxRequestRepeatCount: 4)

        let first = GetPaymentStatePayload.fake(status: .new)
        let error = NSError(domain: "error", code: 123456)

        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldCalls = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs =
            [.success(first), .failure(error), .failure(error), .failure(error)]

        let data = FullPaymentData(paymentProcess: PaymentProcessMock(), payload: first, cardId: nil, rebillId: nil)

        // when
        sut.startUpdateStatusIfNeeded(data: data)

        // then
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 4)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 4)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, data.payload.paymentId)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFinalStatusRecievedCallsCount, 0)
        XCTAssertEqual(paymentStatusUpdateServiceDelegateMock.paymentFailureStatusRecievedCallsCount, 1)
    }
}

// MARK: - Private methods

extension PaymentStatusUpdateServiceTests {
    private func setupSut(maxRequestRepeatCount: Int = 10) {
        paymentStatusServiceMock = PaymentStatusServiceMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()
        paymentStatusUpdateServiceDelegateMock = PaymentStatusUpdateServiceDelegateMock()

        sut = PaymentStatusUpdateService(
            paymentStatusService: paymentStatusServiceMock,
            repeatedRequestHelper: repeatedRequestHelperMock,
            maxRequestRepeatCount: maxRequestRepeatCount
        )

        sut.delegate = paymentStatusUpdateServiceDelegateMock
    }
}
