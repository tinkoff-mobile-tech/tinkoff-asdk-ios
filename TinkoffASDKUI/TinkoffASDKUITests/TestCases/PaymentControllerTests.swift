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

        threeDSWebFlowControllerMock.confirm3DSCompletionStub = .succeded(getPaymentStatePayload)
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
        threeDSWebFlowControllerMock.confirm3DSACSCompletionInput = .succeded(fakedGetPaymentState)

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
        XCTAssertEqualTypes(tdsControllerMock.doChallengeCallCounter, 1)
        XCTAssertEqual(cancelBlockTriggerCount, .zero)
        XCTAssertEqual(completionBlockTriggerCount, .zero)

        // then
        tdsControllerMock.cancelHandler?()
        tdsControllerMock.completionHandler?(.success(.fake()))

        XCTAssertEqual(cancelBlockTriggerCount, 1)
        XCTAssertEqual(completionBlockTriggerCount, 1)
    }
}

private extension String {
    static let appBasedVersion = "2.1.0"
}
