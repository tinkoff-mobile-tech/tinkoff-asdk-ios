//
//  YandexPayPaymentProcess.swift
//  TinkoffASDKUITests
//
//  Created by Ivan Glushko on 19.04.2023
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

extension XCTest {

    func XCTAssertEqualTypes<T, U>(_ first: @autoclosure () throws -> T, _ second: @autoclosure () throws -> U) {
        do {
            let firstValue = try first()
            let secondValue = try second()
            let firstMetatype = type(of: firstValue as Any)
            let secondMetatype = type(of: secondValue as Any)
            XCTAssert(
                firstMetatype == secondMetatype,
                "Type of \(firstMetatype) is not equal to \(secondMetatype)"
            )
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}

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
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DsConfirmationCallCounter, 1)
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
        paymentProcessDelegateMock.paymentNeed3DsConfirmationCompletionInput = .success(fakedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DsConfirmationPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DsConfirmationCallCounter, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
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
        paymentProcessDelegateMock.paymentNeed3DsConfirmationCancelledInput = ()

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DsConfirmationPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DsConfirmationCallCounter, 1)
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
        paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCompletionInput = .success(fakedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationACSPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCallCounter, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
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
        paymentProcessDelegateMock.paymentNeed3DSConfirmationACSConfirmationCancelledInput = ()

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationACSPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCallCounter, 1)
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
        paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCompletionInput = .success(fakedGetPaymentState)

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter, 1)
        XCTAssertEqual(threeDSDeviceInfoProviderMock.invokedCreateDeviceInfoCount, 1)
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
        paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedConfirmationCancelledInput = ()

        // when
        sut.start()

        // then
        let arguments = paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter, 1)
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
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationAppBasedCallCounter, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DSConfirmationACSCallCounter, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeed3DsConfirmationCallCounter, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFinishCallCounter, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentNeedCollect3DsCallCounter, .zero)
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFailedCallCounter, .zero)
    }
}

// MARK: - Helpers

extension YandexPayPaymentProcessTests {

    private func assertCalledDelegateDidFail(sut: YandexPayPaymentProcess) throws {
        let didFailedArguments = paymentProcessDelegateMock.paymentDidFailedPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFailedCallCounter, 1)
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
        let didFinishArguments = paymentProcessDelegateMock.paymentDidFinishPassedArguments
        XCTAssertEqual(paymentProcessDelegateMock.paymentDidFinishCallCounter, 1)
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
