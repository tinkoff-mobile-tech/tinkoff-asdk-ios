//
//  YandexPayPaymentFlowTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI
import XCTest

final class YandexPayPaymentFlowTests: BaseTestCase {

    var sut: YandexPayPaymentFlow!

    // Mocks
    var yandexPayPaymentSheetAssemblyMock: YandexPayPaymentSheetAssemblyMock!
    var yandexPayPaymentFlowDelegateMock: YandexPayPaymentFlowDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        yandexPayPaymentSheetAssemblyMock = YandexPayPaymentSheetAssemblyMock()
        yandexPayPaymentFlowDelegateMock = YandexPayPaymentFlowDelegateMock()

        sut = YandexPayPaymentFlow(
            yandexPayPaymentSheetAssembly: yandexPayPaymentSheetAssemblyMock,
            delegate: yandexPayPaymentFlowDelegateMock
        )
    }

    override func tearDown() {
        yandexPayPaymentSheetAssemblyMock = nil
        yandexPayPaymentFlowDelegateMock = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_start() {
        allureId(2358072) // Запуск процесса оплаты
        allureId(2358049, "Начинаем проводить платеж, если ASDK получил платежный токен от SDK YP")
        // given

        let fakedPaymentFlow = PaymentFlow.fake()
        let fakedToken = "234234234234dfdsf3fs32423dsddsf"
        let viewControllerMock = UIViewControllerMock()

        yandexPayPaymentFlowDelegateMock.yandexPayPaymentFlowDidRequestViewControllerForPresentationReturnValue = viewControllerMock

        yandexPayPaymentSheetAssemblyMock.yandexPayPaymentSheetReturnValue = UIViewControllerMock()

        // when
        sut.start(with: fakedPaymentFlow, base64Token: fakedToken)

        // then
        let sheetArguments = yandexPayPaymentSheetAssemblyMock.yandexPayPaymentSheetReceivedArguments
        XCTAssertEqual(yandexPayPaymentSheetAssemblyMock.yandexPayPaymentSheetCallsCount, 1)
        XCTAssertEqual(sheetArguments?.paymentFlow, fakedPaymentFlow)
        XCTAssertEqual(sheetArguments?.base64Token, fakedToken)
        XCTAssertEqual(viewControllerMock.invokedPresentAnimatedCount, 1)
    }

    func test_yandexPayPaymentSheet_completedWith() {
        // when
        sut.yandexPayPaymentSheet(completedWith: .cancelled())

        // then
        XCTAssertEqual(yandexPayPaymentFlowDelegateMock.didCompleteWithCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentFlowDelegateMock.didCompleteWithReceivedArguments?.result, .cancelled())
    }
}
