//
//  TinkoffPayControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Никита Васильев on 31.05.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class TinkoffPayControllerTests: BaseTestCase {
    /// Dependencies
    private var paymentService: AcquiringPaymentsServiceMock!
    private var tinkoffPayServiceMock: AcquiringTinkoffPayServiceMock!
    private var applicationOpenerMock: UIApplicationMock!
    private var paymentStatusServiceMock: PaymentStatusServiceMock!
    private var repeatedRequestHelperMock: RepeatedRequestHelperMock!
    private var queueMock: DispatchQueueMock!
    private var delegateMock: TinkoffPayControllerDelegateMock!

    // MARK: - Setup

    override func tearDown() {
        paymentService = nil
        paymentService = nil
        tinkoffPayServiceMock = nil
        applicationOpenerMock = nil
        paymentStatusServiceMock = nil
        repeatedRequestHelperMock = nil
        queueMock = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_thatControllerSendsRequest() {
        allureId(2500814, "Каждые 3 сек отправляется запрос /v2/GetState")
        allureId(2500852, "Отображение \"Время оплаты истекло\" по истечению таймера")

        // given
        let sut = prepareSut(paymentStatusRetriesCount: 10)
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = (0 ... .paymentStatusRetriesCount).map { _ in
            .success(.fake(status: .checking3ds))
        }
        applicationOpenerMock.canOpenURLReturnValue = true
        applicationOpenerMock.openCompletionClosureInput = true
        queueMock.asyncWorkShouldExecute = true

        // when
        sut.performPayment(paymentFlow: .finish(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(paymentStatusServiceMock.getPaymentStateCallsCount, .paymentStatusRetriesCount)
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithTimeoutCallsCount, 1)
    }

    func test_thatControllerShowsTimeoutMessage_whenStatusIsDeadlineExpired() {
        allureId(2500854, "Отображение \"Время оплаты истекло\" получили статус DEADLINE_EXPIRED")

        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.fake(status: .deadlineExpired))]
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        applicationOpenerMock.canOpenURLReturnValue = true
        applicationOpenerMock.openCompletionClosureInput = true
        queueMock.asyncWorkShouldExecute = true

        // when
        sut.performPayment(paymentFlow: .finish(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithTimeoutCallsCount, 1)
    }

    func test_thatControllerNotifiesDelegate_whenStatusIsSuccess() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = true
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.fake(status: .authorized))]

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerDidOpenTinkoffPayCallsCount, 1)
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithSuccessfulCallsCount, 1)
    }

    func test_thatControllerNotifiesDelegate_whenStatusIsFailed() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = true
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.fake(status: .rejected))]

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithFailedCallsCount, 1)
    }

    func test_thatControllerRetriesRequest_whenStatusIsSuccess() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 2)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = true
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.fake(status: .checked3ds))]

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerDidReceiveIntermediateCallsCount, 1)
    }

    func test_thatControllerCompletesWithTimeout_whenStatusIsSuccess() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = true
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.success(.fake(status: .checked3ds))]

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithTimeoutCallsCount, 1)
    }

    func test_thatControllerRetriesRequest_whenStatusIsFailed() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 2)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = true
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.failure(ErrorStub())]

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(repeatedRequestHelperMock.executeWithWaitingIfNeededCallsCount, 2)
    }

    func test_thatControllerCompletesWithError_whenStatusIsFailed() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = true
        repeatedRequestHelperMock.executeWithWaitingIfNeededActionShouldExecute = true
        paymentStatusServiceMock.getPaymentStateCompletionClosureInputs = [.failure(ErrorStub())]

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithCallsCount, 1)
    }

    func test_thatControllerNotifiesDelegate_whenErrorOccurred() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        paymentService.initPaymentCompletionInput = .failure(ErrorStub())

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithCallsCount, 1)
    }

    func test_thatControllerNotifiesDelegate_whenGetLinkErrorOccurred() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .failure(ErrorStub())

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedWithCallsCount, 1)
    }

    func test_thatControllerNotifiesDelegate_whenUnableToOpenExternalApp() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        queueMock.asyncWorkShouldExecute = true

        paymentService.initPaymentCompletionInput = .success(.fake())
        tinkoffPayServiceMock.getTinkoffPayLinkCompletionClosureInput = .success(.fake())
        applicationOpenerMock.openCompletionClosureInput = false

        // when
        sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())

        // then
        XCTAssertEqual(delegateMock.tinkoffPayControllerCompletedDueToInabilityToOpenTinkoffPayCallsCount, 1)
    }

    func test_thatControllerCancelsRequest_whenStatusIsSuccess() {
        // given
        let sut = prepareSut(paymentStatusRetriesCount: 1)

        paymentService.initPaymentCompletionInput = .success(.fake())

        // when
        let process = sut.performPayment(paymentFlow: .full(paymentOptions: .fake()), method: .fake())
        process.cancel()

        // then
        XCTAssertEqual((process as? TinkoffPayController.Process)?.isActive, false)
    }

    func test_errorLocalization_whenCouldNotOpenTinkoffPayApp() {
        // given
        let url = URL(string: "https://vk.com/")!

        // when
        let tpayError = TinkoffPayController.Error.couldNotOpenTinkoffPayApp(url: url)

        // then
        XCTAssertEqual(tpayError.errorDescription, "Could not open TinkoffPay App with url \(url)")
        XCTAssertEqual(
            tpayError.recoverySuggestion,
            url.scheme.map { "For Tinkoff Pay to work correctly, add the scheme \($0) to the list of LSApplicationQueriesSchemes at info.plist" }
        )
    }

    func test_errorLocalization_whenDidNotWaitForSuccessfulPaymentState() {
        // given
        let payload = GetPaymentStatePayload.fake()
        let error = ErrorStub()

        // when
        let tpayError = TinkoffPayController.Error.didNotWaitForSuccessfulPaymentState(
            lastReceivedPaymentState: payload,
            underlyingError: error
        )

        // then
        XCTAssertEqual(
            tpayError.errorDescription,
            "Something went wrong in the payment process: the payment did not reach final status completed. Last received payment payload: \(payload). Underlying error: \(error)"
        )
        XCTAssertNil(tpayError.recoverySuggestion)
    }

    func test_errorLocalization_whenDidNotWaitForSuccessfulPaymentStateAndValuesAreNil() {
        // when
        let tpayError = TinkoffPayController.Error.didNotWaitForSuccessfulPaymentState(
            lastReceivedPaymentState: nil,
            underlyingError: nil
        )

        // then
        XCTAssertEqual(
            tpayError.errorDescription,
            "Something went wrong in the payment process: the payment did not reach final status completed"
        )
        XCTAssertNil(tpayError.recoverySuggestion)
    }

    func test_errorLocalization_whenDidReceiveFailedPaymentState() {
        // given
        let payload = GetPaymentStatePayload.fake()

        // when
        let tpayError = TinkoffPayController.Error.didReceiveFailedPaymentState(payload)

        // then
        XCTAssertEqual(
            tpayError.errorDescription,
            "Something went wrong in the payment process: the payment was rejected. Payload: \(payload)"
        )
        XCTAssertNil(tpayError.recoverySuggestion)
    }

    // MARK: - Private

    private func prepareSut(paymentStatusRetriesCount: Int) -> TinkoffPayController {
        paymentService = AcquiringPaymentsServiceMock()
        paymentService = AcquiringPaymentsServiceMock()
        tinkoffPayServiceMock = AcquiringTinkoffPayServiceMock()
        applicationOpenerMock = UIApplicationMock()
        paymentStatusServiceMock = PaymentStatusServiceMock()
        repeatedRequestHelperMock = RepeatedRequestHelperMock()
        queueMock = DispatchQueueMock()
        delegateMock = TinkoffPayControllerDelegateMock()
        let sut = TinkoffPayController(
            paymentService: paymentService,
            tinkoffPayService: tinkoffPayServiceMock,
            applicationOpener: applicationOpenerMock,
            paymentStatusService: paymentStatusServiceMock,
            repeatedRequestHelper: repeatedRequestHelperMock,
            paymentStatusRetriesCount: paymentStatusRetriesCount,
            mainDispatchQueue: queueMock
        )
        sut.delegate = delegateMock
        return sut
    }
}

private extension Int {
    static let paymentStatusRetriesCount = 10
}
