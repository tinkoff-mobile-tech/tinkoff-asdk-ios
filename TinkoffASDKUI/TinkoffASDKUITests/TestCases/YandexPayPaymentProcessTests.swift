//
//  YandexPayPaymentProcess.swift
//  TinkoffASDKUITests
//
//  Created by Ivan Glushko on 19.04.2023
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class YandexPayPaymentProcessTests: BaseTestCase {

    // Mocks

    var paymentServiceMock: AcquiringPaymentsServiceMock!
    var threeDSDeviceInfoProviderMock: ThreeDSDeviceInfoProviderMock!
    var paymentProcessDelegateMock: PaymentProcessDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        paymentServiceMock = AcquiringPaymentsServiceMock()
        threeDSDeviceInfoProviderMock = ThreeDSDeviceInfoProviderMock()
        paymentProcessDelegateMock = PaymentProcessDelegateMock()
    }

    override func tearDown() {
        paymentServiceMock = nil
        threeDSDeviceInfoProviderMock = nil
        paymentProcessDelegateMock = nil

        super.tearDown()
    }

    // MARK: - PaymentFLow - Full

    /// Инициализация платежа в полном флоу
    func test_start_paymentFlow_full_success_3dsV1() {
        allureId(2358072, "ASDK подтверждает прохождение 3DS v1 (web-view)")

        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let initPayload = InitPayload(amount: 100, orderId: "23", paymentId: "132", status: .checking3ds)
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DS(.fake()))

        paymentServiceMock.initPaymentCompletionInput = .success(initPayload)
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)

        // when
        sut.start()

        // then
        XCTAssertEqual(paymentServiceMock.initPaymentCallCounter, 1)
        XCTAssertEqual(paymentServiceMock.finishAuthorizeCallCounter, 1)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationCallsCount, 1)
    }

    func test_start_paymentFlow_full_failure() throws {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        paymentServiceMock.initPaymentCompletionInput = .failure(TestsError.basic)

        // when
        sut.start()

        // then
        try assertCalledDelegateDidFail(sut: sut)
    }

    // MARK: - PaymentFLow - Finish

    func test_start_paymentFlow_finish_success_3dsV1() {
        allureId(2358072, "ASDK подтверждает прохождение 3DS v1 (web-view)")

        // given
        let sut = prepareSut(paymentFlow: .finish(paymentOptions: .fake()))
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DS(.fake()))
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)

        // when
        sut.start()

        // then
        XCTAssertEqual(paymentServiceMock.initPaymentCallCounter, 0)
        XCTAssertEqual(paymentServiceMock.finishAuthorizeCallCounter, 1)
    }

    func test_start_paymentFlow_finish_failure() throws {
        // given
        let sut = prepareSut(paymentFlow: .finish(paymentOptions: .fake()))
        paymentServiceMock.finishAuthorizeCompletionInput = .failure(TestsError.basic)

        // when
        sut.start()

        // then
        try assertCalledDelegateDidFail(sut: sut)
    }

    // MARK: - Finish Authorize Tests for Full Payment Flow

    /// No confirmation needed
    func test_finishAuthorize_done() throws {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let initPayload = InitPayload(amount: 100, orderId: "23", paymentId: "132", status: .checking3ds)
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .done(.fake()))
        let expectedGetPaymentState = finishPayload.paymentState

        paymentServiceMock.initPaymentCompletionInput = .success(initPayload)
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)

        // when
        sut.start()

        // then
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: expectedGetPaymentState)
    }

    /// 3DS V1 WebView - Completion
    func test_finishAuthorize_needConfirmation3DS_completion() throws {
        allureId(2358067, "Инициализация web-view 3DS v1 по ответу v2/FinishAuthorize")

        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let initPayload = InitPayload(amount: 100, orderId: "23", paymentId: "132", status: .checking3ds)
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DS(.fake()))
        let fakedGetPaymentState = GetPaymentStatePayload.fake(status: .confirmed)

        paymentServiceMock.initPaymentCompletionInput = .success(initPayload)
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)
        paymentProcessDelegateMock.paymentNeed3DSConfirmationCompletionClosureInput = .success(fakedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.createDeviceInfoCallsCount, 1)
        let paymentProcess = try XCTUnwrap(arguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: fakedGetPaymentState)
    }

    /// 3DS V1 WebView - Cancellation
    func test_finishAuthorize_needConfirmation3DS_confirmationCancelled() throws {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let initPayload = InitPayload(amount: 100, orderId: "23", paymentId: "132", status: .checking3ds)
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DS(.fake()))
        let expectedGetPaymentState = GetPaymentStatePayload.fake(status: .cancelled)

        paymentServiceMock.initPaymentCompletionInput = .success(initPayload)
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)
        paymentProcessDelegateMock.paymentNeed3DSConfirmationCompletionClosureInput = .success(expectedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationCallsCount, 1)
        let paymentProcess = try XCTUnwrap(arguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: expectedGetPaymentState)
    }

    /// 3DS V2 WebView - Completion
    func test_finishAuthorize_needConfirmation3DSACS_completion() throws {
        allureId(2358058)

        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DSACS(.fake()))
        let fakedGetPaymentState = GetPaymentStatePayload.fake(status: .confirmed)

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)
        paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCompletionClosureInput = .success(fakedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationACSReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.createDeviceInfoCallsCount, 1)
        let paymentProcess = try XCTUnwrap(arguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: fakedGetPaymentState)
    }

    /// 3DS V2 WebView - Cancellation
    func test_finishAuthorize_needConfirmation3DSACS_confirmationCancelled() throws {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DSACS(.fake()))

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)
        paymentProcessDelegateMock.paymentNeed3DSConfirmationACSConfirmationCancelledShouldExecute = true

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationACSReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCallsCount, 1)
        let paymentProcess = try XCTUnwrap(arguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: .fake(status: .cancelled))
    }

    /// 3DS V2.1 App Based - Completion
    func test_finishAuthorize_needConfirmation3DS2AppBased_completion() throws {
        allureId(2358075, "ASDK подтверждает прохождение 3DS v2 (app-based)")
        allureId(2358051) // Для авторизации платежа передаем необходимые параметры

        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DS2AppBased(.fake()))
        let fakedGetPaymentState = GetPaymentStatePayload.fake(status: .confirmed)

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)
        paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCompletionClosureInput = .success(fakedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.createDeviceInfoCallsCount, 1)
        let paymentProcess = try XCTUnwrap(arguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: fakedGetPaymentState)
    }

    /// 3DS V2.1 App Based - Cancellation
    func test_finishAuthorize_needConfirmation3DS2AppBased_confirmationCancelled() throws {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .needConfirmation3DS2AppBased(.fake()))

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)
        paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedConfirmationCancelledShouldExecute = true

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount, 1)
        let paymentProcess = try XCTUnwrap(arguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        try assertCalledDelegateDidFinish(sut: sut, fakedGetPaymentState: .fake(status: .cancelled))
    }

    /// Unknown
    func test_finishAuthorize_unknown() throws {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        let finishPayload = FinishAuthorizePayload.fake(responseStatus: .unknown)

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.finishAuthorizeCompletionInput = .success(finishPayload)

        // when
        sut.start()

        // then
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCallsCount, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCallsCount, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationCallsCount, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFinishWithCallsCount, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeedToCollect3DSDataCallsCount, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFailedWithCallsCount, .zero)
    }

    func test_returnPaymentId_whenPaymentFlowIsFull() {
        // given
        let payloadMock = InitPayload.fake()
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))
        paymentServiceMock.initPaymentCompletionInput = .success(.fake())

        // when
        sut.start()
        let paymentId = sut.paymentId

        // then
        XCTAssertEqual(paymentId, payloadMock.paymentId)
    }

    func test_returnPaymentId_whenPaymentFlowIsFinish() {
        // given
        let paymentOptions = FinishPaymentOptions.fake()
        let sut = prepareSut(paymentFlow: .finish(paymentOptions: paymentOptions))
        paymentServiceMock.initPaymentCompletionInput = .success(.fake())

        // when
        sut.start()
        let paymentId = sut.paymentId

        // then
        XCTAssertEqual(paymentId, paymentOptions.paymentId)
    }

    func test_cancelRequestCancels() {
        // given
        let mockCancellable = CancellableMock()
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.initPaymentStubReturn = { _ in
            mockCancellable
        }

        // when
        sut.start()
        sut.cancel()

        // then
        XCTAssertTrue(mockCancellable.invokedCancel)
    }

    func test_thatPaymentProcessNotifiesDelegate() {
        // given
        let sut = prepareSut(paymentFlow: .full(paymentOptions: .fake()))

        paymentServiceMock.initPaymentCompletionInput = .success(.fake())
        paymentServiceMock.finishAuthorizeCompletionInput = .success(.fake(responseStatus: .needConfirmation3DS(.fake())))

        paymentProcessDelegateMock.paymentNeed3DSConfirmationCompletionClosureInput = .failure(ErrorStub())

        // when
        sut.start()

        // then
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFailedWithCallsCount, 1)
    }
}

// MARK: - Helpers

extension YandexPayPaymentProcessTests {

    private func assertCalledDelegateDidFail(sut: YandexPayPaymentProcess) throws {
        let didFailedArguments = paymentProcessDelegateMock.paymentDidFailedWithReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFailedWithCallsCount, 1)
        XCTAssertEqual(didFailedArguments?.cardId, nil)
        XCTAssertEqual(didFailedArguments?.rebillId, nil)
        let error = try XCTUnwrap(didFailedArguments?.error)
        let paymentProcess = try XCTUnwrap(didFailedArguments?.paymentProcess)
        XCTAssertEqual(error as? TestsError, .basic)
        XCTAssertEqualTypes(paymentProcess, sut)
    }

    private func assertCalledDelegateDidFinish(
        sut: YandexPayPaymentProcess,
        fakedGetPaymentState: GetPaymentStatePayload
    ) throws {
        let didFinishArguments = paymentProcessDelegateMock.paymentDidFinishWithReceivedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFinishWithCallsCount, 1)
        let paymentProcess = try XCTUnwrap(didFinishArguments?.paymentProcess)
        XCTAssertEqualTypes(paymentProcess, sut)
        XCTAssertEqual(didFinishArguments?.state, fakedGetPaymentState)
    }

    private func prepareSut(paymentFlow: PaymentFlow, base64Token: String = "") -> YandexPayPaymentProcess {
        YandexPayPaymentProcess(
            paymentFlow: paymentFlow,
            paymentSource: .yandexPay(base64Token: base64Token),
            paymentService: paymentServiceMock,
            threeDSDeviceInfoProvider: threeDSDeviceInfoProviderMock,
            delegate: paymentProcessDelegateMock
        )
    }
}
