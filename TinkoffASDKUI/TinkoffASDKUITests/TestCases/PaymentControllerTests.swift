//
//  PaymentControllerTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 19.04.2023.
//

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

final class PaymentControllerTests: BaseTestCase {

    var sut: PaymentController!

    // Mocks

    var paymentFactoryMock: PaymentFactoryMock!
    var threeDSWebFlowControllerMock: ThreeDSWebFlowControllerMock!
    var threeDSServiceMock: AcquiringThreeDsServiceMock!
    var threeDSDeviceInfoProviderMock: ThreeDSDeviceInfoProviderMock!
    var tdsControllerMock: TDSControllerMock!
    var paymentStatusUpdateServiceMock: PaymentStatusUpdateServiceMock!
    var paymentProcessMock: PaymentProcessMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        paymentFactoryMock = PaymentFactoryMock()
        threeDSWebFlowControllerMock = ThreeDSWebFlowControllerMock()
        threeDSServiceMock = AcquiringThreeDsServiceMock()
        threeDSDeviceInfoProviderMock = ThreeDSDeviceInfoProviderMock()
        tdsControllerMock = TDSControllerMock()
        paymentStatusUpdateServiceMock = PaymentStatusUpdateServiceMock()
        paymentProcessMock = PaymentProcessMock()

        sut = PaymentController(
            paymentFactory: paymentFactoryMock,
            threeDSWebFlowController: threeDSWebFlowControllerMock,
            threeDSService: threeDSServiceMock,
            threeDSDeviceInfoProvider: threeDSDeviceInfoProviderMock,
            tdsController: tdsControllerMock,
            paymentStatusUpdateService: paymentStatusUpdateServiceMock
        )
    }

    override func tearDown() {
        paymentFactoryMock = nil
        threeDSWebFlowControllerMock = nil
        threeDSServiceMock = nil
        threeDSDeviceInfoProviderMock = nil
        tdsControllerMock = nil
        paymentStatusUpdateServiceMock = nil
        paymentProcessMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_get_webFlowDelegate() {
        // given
        let webFlowDelegateMock = ThreeDSWebFlowDelegateMock()
        threeDSWebFlowControllerMock.webFlowDelegate = webFlowDelegateMock

        // when
        let webFlowDelegate = sut.webFlowDelegate as? ThreeDSWebFlowDelegateMock

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.webFlowDelegate as? ThreeDSWebFlowDelegateMock, webFlowDelegate)
    }

    func test_set_webFlowDelegate() {
        // given
        let webFlowDelegateMock = ThreeDSWebFlowDelegateMock()

        // when
        sut.webFlowDelegate = webFlowDelegateMock
        let webFlowDelegate = sut.webFlowDelegate as? ThreeDSWebFlowDelegateMock

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.webFlowDelegate as? ThreeDSWebFlowDelegateMock, webFlowDelegate)
    }

    func test_need3DSConfirmation_success() {
        allureId(2358072) // ASDK совершил редирект на ACSurl для прохождения 3DS v1
        allureId(2358067, "Инициализация web-view 3DS v1 по ответу v2/FinishAuthorize")

        // given
        let confirmation3DSData = Confirmation3DSData.fake()
        let getPaymentStatePayload = GetPaymentStatePayload(
            paymentId: "324",
            amount: 100,
            orderId: "4234",
            status: .authorized
        )

        threeDSWebFlowControllerMock.confirm3DSCompletionClosureInput = .succeded(getPaymentStatePayload)
        var receivedResult: Result<GetPaymentStatePayload, Error>?

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmation: confirmation3DSData,
            confirmationCancelled: {},
            completion: { result in
                receivedResult = result
            }
        )

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSCallsCount, 1)
        XCTAssertEqual(
            confirmation3DSData.acsUrl,
            threeDSWebFlowControllerMock.confirm3DSReceivedArguments?.data.acsUrl
        )

        let payload = try? receivedResult?.get()
        XCTAssertEqual(payload, getPaymentStatePayload)
    }

    func test_need3DSConfirmationACS_success() throws {
        allureId(2358058, "Инициализация web-view 3DS v2 по ответу v2/FinishAuthorize")

        // given
        let fakedGetPaymentState = GetPaymentStatePayload.fake()
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .succeded(fakedGetPaymentState)

        // when
        var completionValue: GetPaymentStatePayload?

        sut.payment(
            paymentProcessMock,
            need3DSConfirmationACS: .fake(),
            version: "2.0.0",
            confirmationCancelled: {},
            completion: { result in
                completionValue = try? result.get()
            }
        )

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 1)
        let value = try XCTUnwrap(completionValue)
        XCTAssertEqual(fakedGetPaymentState, value)
    }

    func test_need3DSConfirmationACS_failure() throws {
        // given
        let error = NSError(domain: "error", code: 123456)
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .failed(error)

        var resultPayload: GetPaymentStatePayload?
        var resultError: NSError?
        let completion: (Result<GetPaymentStatePayload, Error>) -> Void = { result in
            switch result {
            case let .success(payload):
                resultPayload = payload
            case let .failure(err):
                resultError = err as NSError
            }
        }

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmationACS: .fake(),
            version: "2.0.0",
            confirmationCancelled: {},
            completion: completion
        )

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 1)
        XCTAssertEqual(resultPayload, nil)
        XCTAssertEqual(resultError, error)
    }

    func test_need3DSConfirmationACS_canceled() throws {
        // given
        threeDSWebFlowControllerMock.confirm3DSACSCompletionClosureInput = .cancelled

        var isConfirmationCancelledCalled = false
        let confirmationCancelled: () -> Void = { isConfirmationCancelledCalled = true }

        var resultPayload: GetPaymentStatePayload?
        var resultError: NSError?
        let completion: (Result<GetPaymentStatePayload, Error>) -> Void = { result in
            switch result {
            case let .success(payload):
                resultPayload = payload
            case let .failure(err):
                resultError = err as NSError
            }
        }

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmationACS: .fake(),
            version: "2.0.0",
            confirmationCancelled: confirmationCancelled,
            completion: completion
        )

        // then
        XCTAssertEqual(threeDSWebFlowControllerMock.confirm3DSACSCallsCount, 1)
        XCTAssertTrue(isConfirmationCancelledCalled)
        XCTAssertEqual(resultPayload, nil)
        XCTAssertEqual(resultError, nil)
    }

    func test_performPayment_yandexPay() {
        allureId(2358072) // Создаем и запускаем процесс оплаты через YandexPayPaymentProcess
        allureId(2358049)

        // given
        let pamentFlow = PaymentFlow.fake()
        let paymentSource = PaymentSourceData.yandexPay(base64Token: "base64Token")
        paymentFactoryMock.createPaymentStubReturn = paymentProcessMock

        // when
        sut.performPayment(
            paymentFlow: pamentFlow,
            paymentSource: paymentSource
        )

        // then
        let createPaymentArguments = paymentFactoryMock.createPaymentPassedArguments
        XCTAssertEqual(paymentFactoryMock.createPaymentCallCounter, 1)
        XCTAssertEqual(createPaymentArguments?.paymentSource, paymentSource)
        XCTAssertEqual(createPaymentArguments?.paymentFlow, pamentFlow)
        XCTAssert(createPaymentArguments?.paymentDelegate === sut)
        XCTAssertEqual(paymentProcessMock.startCallsCount, 1)
    }

    func test_need3DSConfirmationAppBased() throws {
        allureId(2358075)

        // given
        var cancelBlockTriggerCount = 0
        var completionBlockTriggerCount = 0

        let cancelBlock = { cancelBlockTriggerCount += 1 }
        let completionBlock: (Result<GetPaymentStatePayload, Error>) -> Void = { _ in
            completionBlockTriggerCount += 1
        }

        // when
        sut.payment(
            paymentProcessMock,
            need3DSConfirmationAppBased: .fake(),
            version: .appBasedVersion,
            confirmationCancelled: cancelBlock,
            completion: completionBlock
        )

        // then
        XCTAssertEqual(tdsControllerMock.doChallengeCallCounter, 1)
        XCTAssertEqual(cancelBlockTriggerCount, .zero)
        XCTAssertEqual(completionBlockTriggerCount, .zero)

        // then
        tdsControllerMock.cancelHandler?()
        tdsControllerMock.completionHandler?(.success(.fake()))

        XCTAssertEqual(cancelBlockTriggerCount, 1)
        XCTAssertEqual(completionBlockTriggerCount, 1)
    }

    func test_startUpdateStatus_whenPaymentDidFinish() throws {
        // given
        let state = GetPaymentStatePayload.fake()

        // when
        sut.paymentDidFinish(
            paymentProcessMock,
            with: state,
            cardId: .cardId,
            rebillId: .rebillId
        )

        // then
        let data = try XCTUnwrap(paymentStatusUpdateServiceMock.startUpdateStatusIfNeededReceivedArguments)
        XCTAssertEqual(data.cardId, .cardId)
        XCTAssertEqual(data.rebillId, .rebillId)
        XCTAssertEqual(data.payload, state)
    }

    func test_paymentControlleNotifiesChargePaymentDelegate_whenPaymentDidFailed_104() throws {
        // given
        let paymentId = String.paymentId
        let errorStub = NSError(domain: "domain", code: 104)
        let delegateMock = ChargePaymentControllerDelegateMock()
        let additionalData = ["failMapiSessionId": "\(paymentId)", "recurringType": "12"]
        paymentProcessMock.paymentId = paymentId

        sut.delegate = delegateMock

        // when
        sut.paymentDidFailed(
            paymentProcessMock,
            with: errorStub,
            cardId: .cardId,
            rebillId: .rebillId
        )

        // then
        let data = try XCTUnwrap(delegateMock.paymentControllerShouldRepeatWithRebillIdReturnParameters?.data)
        XCTAssertEqual(delegateMock.paymentControllerShouldRepeatWithRebillIdCallCounter, 1)
        XCTAssertEqual(data.rebillId, .rebillId)
        XCTAssertEqual(data.additionalData, additionalData)
    }

    func test_paymentControlleNotifiesChargePaymentDelegate_whenPaymentDidFailed() throws {
        // given
        let paymentId = String.paymentId
        let errorStub = NSError(domain: "domain", code: 111)
        let delegateMock = ChargePaymentControllerDelegateMock()
        paymentProcessMock.paymentId = paymentId

        sut.delegate = delegateMock

        // when
        sut.paymentDidFailed(
            paymentProcessMock,
            with: errorStub,
            cardId: .cardId,
            rebillId: .rebillId
        )

        // then
        XCTAssertEqual(delegateMock.paymentControllerShouldRepeatWithRebillIdCallCounter, 0)
    }

    func test_paymentControllerNotifiesPaymentDelegate_whenPaymentDidFailed() throws {
        // given
        let errorStub = ErrorStub()
        let delegateMock = MockPaymentControllerDelegate()

        sut.delegate = delegateMock

        // when
        sut.paymentDidFailed(
            paymentProcessMock,
            with: errorStub,
            cardId: .cardId,
            rebillId: .rebillId
        )

        // then
        let data = try XCTUnwrap(delegateMock.paymentControllerDidFailedParameters?.data)
        XCTAssertEqual(delegateMock.paymentControllerDidFailedCallCounter, 1)
        XCTAssertEqual(data.rebillId, .rebillId)
        XCTAssertEqual(data.cardId, .cardId)
    }

    func test_paymentControllerNotifiesPaymentDelegate_whenNeedToCollect3DSData() {
        // given
        let data = Checking3DSURLData.fake()
        let deviceInfo = ThreeDSDeviceInfo.fake()
        threeDSDeviceInfoProviderMock.createDeviceInfoReturnValue = deviceInfo

        // when
        var serviceInfo: ThreeDSDeviceInfo?
        sut.payment(
            paymentProcessMock,
            needToCollect3DSData: data,
            completion: { serviceInfo = $0 }
        )

        // then
        let threeDSData = threeDSWebFlowControllerMock.complete3DSMethodReceivedArguments
        XCTAssertEqual(serviceInfo?.cresCallbackUrl, deviceInfo.cresCallbackUrl)
        XCTAssertEqual(serviceInfo?.screenHeight, deviceInfo.screenHeight)
        XCTAssertEqual(serviceInfo?.screenWidth, deviceInfo.screenWidth)
        XCTAssertEqual(threeDSWebFlowControllerMock.complete3DSMethodCallsCount, 1)
        XCTAssertEqual(threeDSData?.notificationURL, data.notificationURL)
        XCTAssertEqual(threeDSData?.tdsServerTransID, data.tdsServerTransID)
        XCTAssertEqual(threeDSData?.notificationURL, data.notificationURL)
    }

    func test_paymentControllerNotifiesPaymentDelegate_whenPaymentFinalStatusReceived() throws {
        // given
        let payload = GetPaymentStatePayload.fake()
        let data = FullPaymentData(
            paymentProcess: paymentProcessMock,
            payload: payload,
            cardId: .cardId,
            rebillId: .rebillId
        )
        let delegateMock = MockPaymentControllerDelegate()

        sut.delegate = delegateMock

        // when
        sut.paymentFinalStatusRecieved(data: data)

        // then
        let receivedData = try XCTUnwrap(delegateMock.paymentControllerDidFinishPaymentParameters?.data)
        XCTAssertEqual(delegateMock.paymentControllerDidFinishPaymentCallCounter, 1)
        XCTAssertEqual(receivedData.rebillId, data.rebillId)
        XCTAssertEqual(receivedData.cardId, data.cardId)
        XCTAssertEqual(receivedData.state, data.payload)
    }

    func test_paymentControllerNotifiesPaymentDelegate_whenPaymentCancelStatusReceived() throws {
        // given
        let payload = GetPaymentStatePayload.fake()
        let data = FullPaymentData(
            paymentProcess: paymentProcessMock,
            payload: payload,
            cardId: .cardId,
            rebillId: .rebillId
        )
        let delegateMock = MockPaymentControllerDelegate()

        sut.delegate = delegateMock

        // when
        sut.paymentCancelStatusRecieved(data: data)

        // then
        let receivedData = try XCTUnwrap(delegateMock.paymentControllerPaymentWasCancelledParameters?.data)
        XCTAssertEqual(delegateMock.paymentControllerPaymentWasCancelledCallCounter, 1)
        XCTAssertEqual(receivedData.rebillId, data.rebillId)
        XCTAssertEqual(receivedData.cardId, data.cardId)
    }

    func test_paymentControllerNotifiesPaymentDelegate_whenPaymentFailureStatusReceived() throws {
        // given
        let payload = GetPaymentStatePayload.fake()
        let data = FullPaymentData(
            paymentProcess: paymentProcessMock,
            payload: payload,
            cardId: .cardId,
            rebillId: .rebillId
        )
        let delegateMock = MockPaymentControllerDelegate()
        let errorStub = ErrorStub()

        sut.delegate = delegateMock

        // when
        sut.paymentFailureStatusRecieved(data: data, error: errorStub)

        // then
        let receivedData = try XCTUnwrap(delegateMock.paymentControllerDidFailedParameters?.data)
        XCTAssertEqual(delegateMock.paymentControllerDidFailedCallCounter, 1)
        XCTAssertEqual(receivedData.rebillId, data.rebillId)
        XCTAssertEqual(receivedData.cardId, data.cardId)
    }
}

private extension String {
    static let appBasedVersion = "2.1.0"
    static let cardId = "cardId"
    static let rebillId = "rebillId"
    static let paymentId = "paymentId"
}
