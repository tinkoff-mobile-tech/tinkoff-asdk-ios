//
//  YandexPayPaymentSheetPresenterTests.swift
//  Pods
//
//  Created by Ivan Glushko on 20.04.2023.
//

import TinkoffASDKCore
@testable import TinkoffASDKUI
import XCTest

private extension String {
    static let base64Token = "base64Token"
}

final class YandexPayPaymentSheetPresenterTests: BaseTestCase {

    typealias State = YandexPayPaymentSheetPresenter.SheetState

    // Sut

    var sut: YandexPayPaymentSheetPresenter!

    // Mocks

    var commonSheetViewMock: CommonSheetViewMock!
    var threeDSWebFlowDelegateMock: ThreeDSWebFlowDelegateMock!
    var paymentControllerMock: PaymentControllerMock!
    var yandexPayPaymentSheetOutputMock: YandexPayPaymentSheetOutputMock!
    var paymentProcessMock: PaymentProcessMock!
    var fakedPaymentFlow: PaymentFlow!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        threeDSWebFlowDelegateMock = ThreeDSWebFlowDelegateMock()
        paymentControllerMock = PaymentControllerMock()
        yandexPayPaymentSheetOutputMock = YandexPayPaymentSheetOutputMock()
        fakedPaymentFlow = PaymentFlow.fake()
        commonSheetViewMock = CommonSheetViewMock()
        paymentProcessMock = PaymentProcessMock()

        sut = YandexPayPaymentSheetPresenter(
            paymentController: paymentControllerMock,
            paymentControllerUIProvider: threeDSWebFlowDelegateMock,
            paymentFlow: fakedPaymentFlow,
            base64Token: .base64Token,
            output: yandexPayPaymentSheetOutputMock
        )

        sut.view = commonSheetViewMock
    }

    override func tearDown() {
        threeDSWebFlowDelegateMock = nil
        paymentControllerMock = nil
        yandexPayPaymentSheetOutputMock = nil
        commonSheetViewMock = nil
        fakedPaymentFlow = nil
        paymentProcessMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() {
        allureId(2358049, "Начинаем проводить платеж, если ASDK получил платежный токен от SDK YP")

        // when
        sut.viewDidLoad()
        let proccessing = State.processing.toCommonSheetState()

        // then
        XCTAssertEqual(commonSheetViewMock.updateCallsCount, 1)
        XCTAssertEqual(commonSheetViewMock.updateReceivedArguments, proccessing)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentFlow, fakedPaymentFlow)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, .yandexPay(base64Token: .base64Token))
    }

    func test_primaryButtonTapped() {
        // when
        sut.primaryButtonTapped()

        // then
        XCTAssertEqual(commonSheetViewMock.closeCallsCount, 1)
    }

    func test_secondaryButtonTapped() {
        // when
        sut.secondaryButtonTapped()

        // then
        XCTAssertEqual(commonSheetViewMock.closeCallsCount, 0)
        XCTAssertEqual(commonSheetViewMock.updateCallsCount, 0)
    }

    func test_canDismissViewByUserInteraction() {
        // when
        let result = sut.canDismissViewByUserInteraction()

        // then
        XCTAssertEqual(result, false)
    }

    func test_viewWasClosed() {
        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetReceivedArguments, .cancelled())
    }

    func test_paymentController_didFinishPayment() {
        allureId(2358054, "Успешная оплата без прохождения 3DS")
        allureId(2358052)
        allureId(2358064)

        // given
        let fakedGetPaymentStatePayload = GetPaymentStatePayload(
            paymentId: "34",
            amount: 324,
            orderId: "",
            status: .cancelled
        )

        let expectedPaymentInfo = fakedGetPaymentStatePayload.toPaymentInfo()

        // when
        sut.paymentController(
            paymentControllerMock,
            didFinishPayment: paymentProcessMock,
            with: fakedGetPaymentStatePayload,
            cardId: "cardId",
            rebillId: nil
        )

        sut.viewWasClosed()

        // then
        XCTAssertEqual(commonSheetViewMock.updateCallsCount, 1)
        XCTAssertEqual(commonSheetViewMock.updateReceivedArguments, State.paid.toCommonSheetState())
        XCTAssertEqual(sut.canDismissViewByUserInteraction(), true)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetReceivedArguments, .succeeded(expectedPaymentInfo))
    }

    func test_paymentController_paymentWasCancelled() {
        allureId(
            2358066,
            "Передаем статус отмены в родительское приложение, если в web-view была совершена отмена пользователем"
        )

        // when
        sut.paymentController(
            paymentControllerMock,
            paymentWasCancelled: paymentProcessMock,
            cardId: nil,
            rebillId: nil
        )

        sut.viewWasClosed()

        // then
        XCTAssertEqual(sut.canDismissViewByUserInteraction(), true)
        XCTAssertEqual(commonSheetViewMock.closeCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetReceivedArguments, .cancelled())
    }

    func test_paymentController_didFailed() {
        allureId(2358053, "Меняем состояние шторки, если v2/FinishAuthorize пришел с ошибкой")
        allureId(2358069, "Передаем ошибку в родительское приложение, если v2/FinishAuthorize пришел с ошибкой")
        allureId(2358071)
        allureId(2358070)
        allureId(2358073)
        allureId(2358062)
        allureId(2358050)
        allureId(2358065)

        // given
        let error = TestsError.basic

        // when
        sut.paymentController(
            paymentControllerMock,
            didFailed: error,
            cardId: nil,
            rebillId: nil
        )

        sut.viewWasClosed()

        // then
        XCTAssertEqual(sut.canDismissViewByUserInteraction(), true)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentSheetOutputMock.yandexPayPaymentSheetReceivedArguments, .failed(error))
        XCTAssertEqual(commonSheetViewMock.updateCallsCount, 1)
        XCTAssertEqual(commonSheetViewMock.updateReceivedArguments, State.failed.toCommonSheetState())
    }
}
