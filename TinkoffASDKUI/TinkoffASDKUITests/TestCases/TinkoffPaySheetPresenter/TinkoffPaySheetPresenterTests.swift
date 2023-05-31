//
//  TinkoffPaySheetPresenterTests.swift
//  TinkoffASDKCore-Unit-Tests
//
//  Created by Никита Васильев on 29.05.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class TinkoffPaySheetPresenterTests: XCTestCase {

    // MARK: Types

    typealias State = CommonSheetState.TinkoffPay

    // MARK: Mocks

    private var tinkoffPayServiceMock: AcquiringTinkoffPayServiceMock!
    private var routerMock: TinkoffPaySheetRouterMock!
    private var tinkoffPayControllerMock: TinkoffPayControllerMock!
    private var viewMock: CommonSheetViewMock!
    private var moduleCompletionMock: PaymentResultCompletion?

    // MARK: Setup

    override func tearDown() {
        tinkoffPayServiceMock = nil
        routerMock = nil
        tinkoffPayControllerMock = nil
        viewMock = nil
        moduleCompletionMock = nil
        super.tearDown()
    }

    // MARK: Tests

    func test_thatPresenterUpdatesViewStateToProcessing_whenViewDidLoad() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let state = State.processing

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateCallsCount, 1)
        XCTAssertEqual(viewMock.updateReceivedArguments?.state, state)
        XCTAssertTrue(viewMock.updateReceivedArguments?.animatePullableContainerUpdates == false)
    }

    func test_thatPresenterRequestsTinkoffPayStatus_whenViewDidLoad() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        // when
        sut.viewDidLoad()

        // then
        XCTAssertTrue(tinkoffPayServiceMock.invokedGetTinkoffPayStatus)
    }

    func test_thatPresenterPerformsPayment_whenStatusIsAllowed() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let method = TinkoffPayMethod.fake()
        tinkoffPayServiceMock.stubbedGetTinkoffPayStatusCompletion = .success(.fake(status: .allowed(method)))

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentCount, 1)
    }

    func test_thatPresenterUpdatesStateToFailed_whenRequestFailed() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        tinkoffPayServiceMock.stubbedGetTinkoffPayStatusCompletion = .failure(ErrorStub())
        let state = State.failedPaymentOnIndependentFlow

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateReceivedArguments?.state, state)
    }

    func test_thatPresenterUpdatesStateToFailed_whenStatusIsDisallowed() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        tinkoffPayServiceMock.stubbedGetTinkoffPayStatusCompletion = .success(.fake(status: .disallowed))
        let state = State.failedPaymentOnIndependentFlow

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.updateReceivedArguments?.state, state)
    }

    func test_thatPresenterClosesView_whenPrimaryButtonDidTap() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        // when
        sut.primaryButtonTapped()

        // then
        XCTAssertEqual(viewMock.closeCallsCount, 1)
    }

    func test_thatPresenterClosesView_whenSecondaryButtonDidTap() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        // when
        sut.secondaryButtonTapped()

        // then
        XCTAssertEqual(viewMock.closeCallsCount, 1)
    }

    func test_thatPresenterPassesResultToModuleCompletionHandler_whenViewWasClosed() {
        // given
        var invokedModuleCompletionResult = false
        var moduleCompletionResult: PaymentResult?
        moduleCompletionMock = { result in
            invokedModuleCompletionResult = true
            moduleCompletionResult = result
        }

        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        // when
        sut.viewWasClosed()

        // then
        XCTAssertTrue(invokedModuleCompletionResult)
        XCTAssertEqual(moduleCompletionResult, .cancelled())
    }

    func test_thatPresenterCanDismissViewByUserInteraction() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        // when
        let value = sut.canDismissViewByUserInteraction()

        // when
        XCTAssertTrue(value)
    }

    func test_thatPresenterOpensTinkoffPayLandingAndSwitchesStateToCancelled_whenLinkWasNotOpened() {
        // given
        let error = ErrorStub()

        // when
        test_thatPresenterChangesState(
            when: { sut in
                sut.tinkoffPayController(
                    tinkoffPayControllerMock,
                    completedDueToInabilityToOpenTinkoffPay: URL.empty,
                    error: error
                )
                sut.viewWasClosed()
            },
            expectedState: State.failedPaymentOnIndependentFlow,
            expectedResult: .failed(error)
        )

        // then
        XCTAssertTrue(routerMock.invokedOpenTinkoffPayLanding)
    }

    func test_thatPresenterChangesStateToCancelled_whenIntermediatePaymentStateDidReceive() {
        // given
        let payload = GetPaymentStatePayload.fake()

        // when
        test_thatPresenterChangesState(
            when: { sut in
                sut.tinkoffPayController(tinkoffPayControllerMock, didReceiveIntermediate: payload)
                sut.viewWasClosed()
            },
            expectedState: nil,
            expectedResult: .cancelled(payload.toPaymentInfo())
        )
    }

    func test_thatPresenterChangesStateToPaid_whenPaymentSucceeded() {
        // given
        let payload = GetPaymentStatePayload.fake()

        // when
        test_thatPresenterChangesState(
            when: { sut in
                sut.tinkoffPayController(tinkoffPayControllerMock, completedWithSuccessful: payload)
                sut.viewWasClosed()
            },
            expectedState: State.paid,
            expectedResult: .succeeded(payload.toPaymentInfo())
        )
    }

    func test_thatPresenterChangesState_whenPaymentCompletedWithFailed() {
        // given
        let error = ErrorStub()

        // when
        test_thatPresenterChangesState(
            when: { sut in
                sut.tinkoffPayController(tinkoffPayControllerMock, completedWithFailed: .fake(), error: error)
                sut.viewWasClosed()
            },
            expectedState: State.failedPaymentOnIndependentFlow,
            expectedResult: .failed(error)
        )
    }

    func test_thatPresenterChangesState_whenPaymentCompletedWithTimeout() {
        // given
        let error = ErrorStub()

        // when
        test_thatPresenterChangesState(
            when: { sut in
                sut.tinkoffPayController(tinkoffPayControllerMock, completedWithTimeout: .fake(), error: error)
                sut.viewWasClosed()
            },
            expectedState: State.timedOutOnIndependentFlow,
            expectedResult: .failed(error)
        )
    }

    func test_thatPresenterChangesState_whenPaymentCompletedWithError() {
        // given
        let error = ErrorStub()

        // when
        test_thatPresenterChangesState(
            when: { sut in
                sut.tinkoffPayController(tinkoffPayControllerMock, completedWith: error)
                sut.viewWasClosed()
            },
            expectedState: State.failedPaymentOnIndependentFlow,
            expectedResult: .failed(error)
        )
    }

    // MARK: Private

    private func test_thatPresenterChangesState(
        when action: (TinkoffPaySheetPresenter) -> Void,
        expectedState: CommonSheetState?,
        expectedResult: PaymentResult
    ) {
        // given
        var moduleCompletionResult: PaymentResult?
        moduleCompletionMock = { result in
            moduleCompletionResult = result
        }
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        // when
        action(sut)

        // then
        XCTAssertEqual(viewMock.updateReceivedArguments?.state, expectedState)
        XCTAssertEqual(moduleCompletionResult, expectedResult)
    }

    private func prepareSut(paymentFlow: PaymentFlow) -> TinkoffPaySheetPresenter {
        tinkoffPayServiceMock = AcquiringTinkoffPayServiceMock()
        routerMock = TinkoffPaySheetRouterMock()
        tinkoffPayControllerMock = TinkoffPayControllerMock()
        viewMock = CommonSheetViewMock()
        let presenter = TinkoffPaySheetPresenter(
            router: routerMock,
            tinkoffPayService: tinkoffPayServiceMock,
            tinkoffPayController: tinkoffPayControllerMock,
            paymentFlow: paymentFlow,
            moduleCompletion: moduleCompletionMock
        )
        presenter.view = viewMock
        return presenter
    }
}
