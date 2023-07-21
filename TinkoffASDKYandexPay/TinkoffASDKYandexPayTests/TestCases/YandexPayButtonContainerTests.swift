//
//  YandexPayButtonContainerTests.swift
//  TinkoffASDKYandexPay-Unit-Tests
//
//  Created by Ivan Glushko on 20.04.2023.
//

@testable import TinkoffASDKUI
@testable import TinkoffASDKYandexPay
import XCTest
import YandexPaySDK

final class YandexPayButtonContainerTests: BaseTestCase {

    var sut: YandexPayButtonContainer!

    // Mocks

    var yandexPaySDKButtonFactoryMock: YandexPaySDKButtonFactoryMock!
    var yPPaymentSheetFactoryMock: YPPaymentSheetFactoryMock!
    var yandexPayPaymentFlowAssemblyMock: YandexPayPaymentFlowAssemblyMock!
    var yandexPayButtonContainerDelegateMock: YandexPayButtonContainerDelegateMock!
    var yandexPayButtonMock: YandexPayButtonMock!
    var yandexPayPaymentFlowMock: YandexPayPaymentFlowMock!

    var configuration: YandexPayButtonContainerConfiguration!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        yandexPayButtonMock = YandexPayButtonMock()
        yandexPaySDKButtonFactoryMock = YandexPaySDKButtonFactoryMock()
        yandexPaySDKButtonFactoryMock.createButtonReturnValue = yandexPayButtonMock

        yPPaymentSheetFactoryMock = YPPaymentSheetFactoryMock()
        yandexPayPaymentFlowAssemblyMock = YandexPayPaymentFlowAssemblyMock()
        yandexPayButtonContainerDelegateMock = YandexPayButtonContainerDelegateMock()
        yandexPayPaymentFlowMock = YandexPayPaymentFlowMock()
        configuration = YandexPayButtonContainerConfiguration(theme: .init(appearance: .light))

        sut = YandexPayButtonContainer(
            configuration: configuration,
            sdkButtonFactory: yandexPaySDKButtonFactoryMock,
            paymentSheetFactory: yPPaymentSheetFactoryMock,
            yandexPayPaymentFlowAssembly: yandexPayPaymentFlowAssemblyMock,
            delegate: yandexPayButtonContainerDelegateMock
        )
    }

    override func tearDown() {
        yandexPaySDKButtonFactoryMock = nil
        yPPaymentSheetFactoryMock = nil
        yandexPayPaymentFlowAssemblyMock = nil
        yandexPayButtonContainerDelegateMock = nil
        yandexPayButtonMock = nil
        yandexPayPaymentFlowMock = nil
        configuration = nil
        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_yandexPayButtonDidRequestViewControllerForPresentation() {
        allureId(2358072) // Инициализирована платежная шторка YP

        // given
        let fakedViewController = UIViewControllerMock()

        yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidRequestViewControllerForPresentationReturnValue = fakedViewController

        // when
        let resultedViewController = sut.yandexPayButtonDidRequestViewControllerForPresentation(yandexPayButtonMock)

        // then
        XCTAssertEqual(
            yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount,
            1
        )

        XCTAssert(fakedViewController === resultedViewController)
    }

    func test_yandexPayButtonDidRequestPaymentSheet() throws {
        allureId(2358072) // Инициализирована платежная шторка YP

        // given
        var receivedYandexPaymentSheet: YPPaymentSheet?
        let fakedPaymentSheet = YPPaymentSheet.fake()
        let paymentFlow = PaymentFlow.full(paymentOptions: .fake())

        yandexPayButtonContainerDelegateMock.yandexPayButtonContainerCompletionClosureInput = paymentFlow
        yPPaymentSheetFactoryMock.createReturnValue = fakedPaymentSheet

        // when
        sut.yandexPayButtonDidRequestPaymentSheet(yandexPayButtonMock, completion: { yandexPaymentSheet in
            receivedYandexPaymentSheet = yandexPaymentSheet
        })

        // then
        let sheet = try XCTUnwrap(receivedYandexPaymentSheet)
        XCTAssertEqual(fakedPaymentSheet, sheet)
        XCTAssertEqual(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerCallsCount, 1)
        XCTAssertEqual(yPPaymentSheetFactoryMock.createCallsCount, 1)
        XCTAssertEqual(yPPaymentSheetFactoryMock.createReceivedArguments, paymentFlow)
    }

    func test_didCompletePaymentWithResult_succeeded() {
        allureId(2358072) // Инициализирована платежная шторка YP, получен ответ от YP
        allureId(2358049)
        allureId(2358051) // Передаем платежный токен для формирования FinishAuthorize
        allureId(2358056)

        // given
        let info = YPPaymentInfo.fake()
        yandexPayPaymentFlowAssemblyMock.yandexPayPaymentFlowReturnValue = yandexPayPaymentFlowMock
        let fakedPaymentFlow = PaymentFlow.fake()
        cachePaymentFlow(flow: fakedPaymentFlow)

        // when
        sut.yandexPayButton(yandexPayButtonMock, didCompletePaymentWithResult: .succeeded(info))

        // then
        XCTAssertEqual(yandexPayPaymentFlowAssemblyMock.yandexPayPaymentFlowCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentFlowMock.startCallsCount, 1)
        XCTAssertEqual(yandexPayPaymentFlowMock.startReceivedArguments?.base64Token, info.paymentToken)
        XCTAssertEqual(yandexPayPaymentFlowMock.startReceivedArguments?.paymentFlow, fakedPaymentFlow)
    }

    func test_didCompletePaymentWithResult_cancelled() throws {
        allureId(2358055, "Передаем статус отмены в родительское приложение, если в YP была совершена отмена пользователем")

        // when
        sut.yandexPayButton(yandexPayButtonMock, didCompletePaymentWithResult: .cancelled)

        // then
        let result = yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments?.result
        XCTAssertEqual(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultCallsCount, 1)
        XCTAssertEqual(result, .cancelled())
    }

    func test_didCompletePaymentWithResult_failed() throws {
        allureId(2358048, "Передаем ошибку в родительское приложение, если YP вернул ошибку")
        let fakedError = YPPaymentError.invalidAmount

        // when
        sut.yandexPayButton(yandexPayButtonMock, didCompletePaymentWithResult: .failed(fakedError))

        // then
        let result = yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments?.result
        let unwrappedResult = try XCTUnwrap(result)
        var isFailedWithError = false
        if case let PaymentResult.failed(error) = unwrappedResult {
            isFailedWithError = (error as? YPPaymentError) == fakedError
        }

        XCTAssertEqual(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultCallsCount, 1)
        XCTAssertTrue(isFailedWithError)
    }

    func test_yandexPayPaymentFlowDidRequestViewControllerForPresentation() {
        // given
        yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidRequestViewControllerForPresentationReturnValue = UIViewControllerMock()
        // when
        let viewController = sut.yandexPayPaymentFlowDidRequestViewControllerForPresentation(yandexPayPaymentFlowMock)
        // then
        XCTAssertEqual(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidRequestViewControllerForPresentationCallsCount, 1)
        XCTAssert(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidRequestViewControllerForPresentationReceivedArguments === sut)
        XCTAssertNotNil(viewController)
    }

    func test_yandexPayPaymentFlow() {
        // when
        sut.yandexPayPaymentFlow(yandexPayPaymentFlowMock, didCompleteWith: .failed(TestsError.basic))
        // then
        XCTAssertEqual(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultCallsCount, 1)
        XCTAssert(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments?.container === sut)
        XCTAssertEqual(yandexPayButtonContainerDelegateMock.yandexPayButtonContainerDidCompletePaymentWithResultReceivedArguments?.result, .failed(TestsError.basic))
    }

    func test_setLoaderVisible() {
        // when
        sut.setLoaderVisible(true, animated: false)
        // then
        XCTAssertEqual(yandexPayButtonMock.setLoaderVisibleCallsCount, 1)
        XCTAssertEqual(yandexPayButtonMock.setLoaderVisibleReceivedArguments?.visible, true)
        XCTAssertEqual(yandexPayButtonMock.setLoaderVisibleReceivedArguments?.animated, false)
    }

    func test_theme() {
        // when
        let receivedTheme = sut.theme
        // then
        XCTAssertEqual(receivedTheme.appearance.hashValue, configuration.theme.appearance.hashValue)
    }

    func test_reloadPersonalizationData() {
        // given
        var error: Error?
        yandexPayButtonMock.reloadPersonalizationDataCompletionClosureInput = TestsError.basic
        // when
        sut.reloadPersonalizationData { err in error = err }
        // then
        XCTAssertEqual(yandexPayButtonMock.reloadPersonalizationDataCallsCount, 1)
        XCTAssertNotNil(error)
    }

    func test_setTheme() {
        let theme = YandexPayButtonContainerTheme(appearance: .dark)
        // when
        sut.setTheme(theme, animated: false)
        // then
        XCTAssertEqual(yandexPayButtonMock.setThemeCallsCount, 1)
        XCTAssertEqual(
            yandexPayButtonMock.setThemeReceivedArguments?.theme.appearance.hashValue,
            theme.appearance.hashValue
        )
        XCTAssertEqual(yandexPayButtonMock.setThemeReceivedArguments?.animated, false)
    }
}

extension YandexPayButtonContainerTests {

    private func cachePaymentFlow(flow: PaymentFlow = .fake()) {
        yandexPayButtonContainerDelegateMock.yandexPayButtonContainerCompletionClosureInput = flow
        yPPaymentSheetFactoryMock.createReturnValue = YPPaymentSheet.fake()

        // кешируем paymentFlow локально в YandexPayButtonContainer
        sut.yandexPayButtonDidRequestPaymentSheet(yandexPayButtonMock, completion: { _ in })
    }
}
