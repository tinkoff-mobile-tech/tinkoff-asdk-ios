//
//  SBPPaymentSheetPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 28.04.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class SBPPaymentSheetPresenterTests: BaseTestCase {

    var sut: SBPPaymentSheetPresenter!

    // MARK: Mocks

    var viewMock: CommonSheetViewMock!
    var paymentSheetOutputMock: SBPPaymentSheetPresenterOutputMock!
    var paymentStatusServiceMock: PaymentStatusServiceMock!
    var repeatedRequestHelperMock: RepeatedRequestHelperMock!
    var mainDispatchQueueMock: DispatchQueueMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut(paymentId: "1234")
    }

    override func tearDown() {
        viewMock = nil
        paymentSheetOutputMock = nil
        paymentStatusServiceMock = nil
        repeatedRequestHelperMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad_when_status_authorized() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .authorized, paymentId: paymentId)

        // when
        sut.viewDidLoad()

        // then
        commonTestsForThenViewDidLoadTests(status: .succeeded, paymentId: paymentId)
    }

    func test_viewDidLoad_when_status_confirmed() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .confirmed, paymentId: paymentId)

        // when
        sut.viewDidLoad()

        // then
        commonTestsForThenViewDidLoadTests(status: .succeeded, paymentId: paymentId)
    }

    func test_viewDidLoad_when_status_rejected() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .rejected, paymentId: paymentId)

        // when
        sut.viewDidLoad()

        // then
        commonTestsForThenViewDidLoadTests(status: .failed, paymentId: paymentId)
    }

    func test_viewDidLoad_when_status_deadlineExpired() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .deadlineExpired, paymentId: paymentId)

        // when
        sut.viewDidLoad()

        // then
        commonTestsForThenViewDidLoadTests(status: .failed, paymentId: paymentId)
    }

    func test_viewDidLoad_when_any_unexpected_status() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .unknown, paymentId: paymentId)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.state, SBPSheetState.waiting.rawValue)
        XCTAssertEqual(viewMock.updateReceivedArguments?.animatePullableContainerUpdates, false)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, paymentId)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
    }

    func test_viewDidLoad_when_any_unexpected_status_should_show_timeout_on_final_request() {
        // given
        let retriesCount = 10
        let paymentId = "11111"
        let status = AcquiringStatus.unknown
        commonSetupsForGivenViewDidLoadTests(status: status, paymentId: paymentId, retriesCount: retriesCount)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = .init(
            repeating: .success(.fake(status: .unknown)),
            count: retriesCount
        )

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 2)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.state, SBPSheetState.waiting.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.state, SBPSheetState.timeout.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.animatePullableContainerUpdates, true)

        for index in 0 ..< retriesCount {
            XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedInvocations[index]?.paymentId, paymentId)
        }
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 10)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 10)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 10)
    }

    func test_viewDidLoad_when_status_formShowed_and_requests_not_allowed() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .formShowed, paymentId: paymentId, retriesCount: 1)

        // when
        sut.viewDidLoad()

        // then
        commonTestsForThenViewDidLoadTests(status: .failed, paymentId: paymentId)
    }

    func test_viewDidLoad_when_status_formShowed_and_requests_allowed() {
        // given
        let paymentId = "11111"
        setupSut(requestRepeatCount: 2, paymentId: paymentId)

        let payload1 = GetPaymentStatePayload.fake(status: .formShowed)
        let payload2 = GetPaymentStatePayload.fake(status: .authorized)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(payload1), .success(payload2)]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 2)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.state, SBPSheetState.paid.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.animatePullableContainerUpdates, true)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.state, SBPSheetState.waiting.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.animatePullableContainerUpdates, false)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, paymentId)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 2)
    }

    func test_viewDidLoad_when_status_confirming() {
        // given
        let paymentId = "11111"
        setupSut(requestRepeatCount: 5, paymentId: paymentId)

        let payload1 = GetPaymentStatePayload.fake(status: .confirming)
        let payload2 = GetPaymentStatePayload.fake(status: .confirming)
        let payload3 = GetPaymentStatePayload.fake(status: .confirming)
        let payload4 = GetPaymentStatePayload.fake(status: .confirming)
        let payload5 = GetPaymentStatePayload.fake(status: .authorized)
        let payloads = [payload1, payload2, payload3, payload4, payload5]
        let results: [Result<GetPaymentStatePayload, Error>] = payloads.map { .success($0) }

        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = results
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 3)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.state, SBPSheetState.waiting.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.state, SBPSheetState.processing.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.animatePullableContainerUpdates, true)
        XCTAssertEqual(viewMock.updateReceivedInvocations[2]?.state, SBPSheetState.paid.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[2]?.animatePullableContainerUpdates, true)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 5)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 5)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, paymentId)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 5)
    }

    func test_viewDidLoad_when_getPaymentStatusFailed_and_requestsAllowed() {
        // given
        let paymentId = "11111"
        setupSut(requestRepeatCount: 2, paymentId: paymentId)

        let error = NSError(domain: "error", code: 1234)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.failure(error), .failure(error)]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 2)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.state, SBPSheetState.waiting.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.state, SBPSheetState.paymentFailed.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.animatePullableContainerUpdates, true)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 2)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, paymentId)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 2)
    }

    func test_primaryButtonTapped() {
        // when
        sut.primaryButtonTapped()

        // then
        XCTAssertEqual(viewMock.closeCallsCount, 1)
    }

    func test_secondaryButtonTapped() {
        // when
        sut.secondaryButtonTapped()

        // then
        XCTAssertEqual(viewMock.closeCallsCount, 1)
    }

    func test_canDismissViewByUserInteraction_true() {
        // when
        let isCanDissmiss = sut.canDismissViewByUserInteraction()

        // then
        XCTAssertTrue(isCanDissmiss)
    }

    func test_canDismissViewByUserInteraction_false() {
        // given
        let paymentId = "11111"
        setupSut(requestRepeatCount: 1, paymentId: paymentId)

        let payload = GetPaymentStatePayload.fake(status: .confirming)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(payload)]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true

        sut.viewDidLoad()

        // when
        let isCanDissmiss = sut.canDismissViewByUserInteraction()

        // then
        XCTAssertFalse(isCanDissmiss)
    }

    func test_viewWasClosed_when_paymentFailed() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .rejected, paymentId: paymentId)
        sut.viewDidLoad()

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .failed(ASDKError(code: .rejected)))
    }

    func test_viewWasClosed_when_timeout() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .deadlineExpired, paymentId: paymentId)
        sut.viewDidLoad()

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .failed(ASDKError(code: .timeout, underlyingError: nil)))
    }

    func test_viewWasClosed_when_processing() {
        // given
        let paymentId = "11111"
        commonSetupsForGivenViewDidLoadTests(status: .authorizing, paymentId: paymentId)
        sut.viewDidLoad()

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 0)
    }

    func test_viewWasClosed_when_waiting() {
        // given
        let paymentId = "11111"
        setupSut(requestRepeatCount: 2, paymentId: paymentId)

        let payload = GetPaymentStatePayload.fake(status: .formShowed)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(payload)]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true
        sut.viewDidLoad()

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .cancelled(payload.toPaymentInfo()))
    }

    func test_viewWasClosed_when_paid_with_info() {
        // given
        let paymentId = "11111"
        setupSut(requestRepeatCount: 2, paymentId: paymentId)

        let payload = GetPaymentStatePayload.fake(status: .authorized)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(payload)]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true
        sut.viewDidLoad()

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetCallsCount, 1)
        XCTAssertEqual(paymentSheetOutputMock.sbpPaymentSheetReceivedArguments, .succeeded(payload.toPaymentInfo()))
    }
}

// MARK: - Private methods

extension SBPPaymentSheetPresenterTests {
    private func setupSut(requestRepeatCount: Int = 10, paymentId: String) {
        viewMock = CommonSheetViewMock()
        paymentSheetOutputMock = SBPPaymentSheetPresenterOutputMock()
        paymentStatusServiceMock = PaymentStatusServiceMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()
        mainDispatchQueueMock = DispatchQueueMock()

        sut = SBPPaymentSheetPresenter(
            output: paymentSheetOutputMock,
            paymentStatusService: paymentStatusServiceMock,
            repeatedRequestHelper: repeatedRequestHelperMock,
            mainDispatchQueue: mainDispatchQueueMock,
            requestRepeatCount: requestRepeatCount,
            paymentId: paymentId
        )

        sut.view = viewMock
    }

    private func commonSetupsForGivenViewDidLoadTests(
        status: AcquiringStatus,
        paymentId: String,
        retriesCount: Int = 5
    ) {
        setupSut(requestRepeatCount: retriesCount, paymentId: paymentId)

        let payload = GetPaymentStatePayload.fake(status: status)
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(payload)]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        mainDispatchQueueMock.asyncWorkShouldExecute = true
    }

    private func commonTestsForThenViewDidLoadTests(status: CommonSheetState.Status, paymentId: String) {
        XCTAssertEqual(viewMock.updateCallsCount, 2)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.state.status, status)
        XCTAssertEqual(viewMock.updateReceivedInvocations[1]?.animatePullableContainerUpdates, true)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.state, SBPSheetState.waiting.rawValue)
        XCTAssertEqual(viewMock.updateReceivedInvocations[0]?.animatePullableContainerUpdates, false)
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, 1)
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateReceivedArguments?.paymentId, paymentId)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
    }
}
