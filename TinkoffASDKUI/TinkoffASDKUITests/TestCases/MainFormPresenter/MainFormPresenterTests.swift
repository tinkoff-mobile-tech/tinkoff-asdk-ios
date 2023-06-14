//
//  MainFormPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 13.06.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class MainFormPresenterTests: BaseTestCase {

    var sut: MainFormPresenter!

    // MARK: Mocks

    var viewMock: MainFormViewControllerMock!
    var routerMock: MainFormRouterMock!
    var mainFormOrderDetailsViewPresenterAssemblyMock: MainFormOrderDetailsViewPresenterAssemblyMock!
    var savedCardViewPresenterAssemblyMock: SavedCardViewPresenterAssemblyMock!
    var switchViewPresenterAssemblyMock: SwitchViewPresenterAssemblyMock!
    var emailViewPresenterAssemblyMock: EmailViewPresenterAssemblyMock!
    var payButtonViewPresenterAssemblyMock: PayButtonViewPresenterAssemblyMock!
    var textAndImageHeaderViewPresenterAssemblyMock: TextAndImageHeaderViewPresenterAssemblyMock!
    var dataStateLoaderMock: MainFormDataStateLoaderMock!
    var paymentControllerMock: PaymentControllerMock!
    var tinkoffPayControllerMock: TinkoffPayControllerMock!
    var cardScannerDelegateMock: CardScannerDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        routerMock = nil
        mainFormOrderDetailsViewPresenterAssemblyMock = nil
        savedCardViewPresenterAssemblyMock = nil
        switchViewPresenterAssemblyMock = nil
        emailViewPresenterAssemblyMock = nil
        payButtonViewPresenterAssemblyMock = nil
        textAndImageHeaderViewPresenterAssemblyMock = nil
        dataStateLoaderMock = nil
        paymentControllerMock = nil
        tinkoffPayControllerMock = nil
        cardScannerDelegateMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad_when_primaryPaymentMethodSbp_success() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let sbpPaymentMethod = MainFormPaymentMethod.sbp
        let dataState = MainFormDataState.any(primaryPaymentMethod: sbpPaymentMethod)
        let cards = dataState.cards
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state, MainFormState.processing.rawValue)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.animatePullableContainerUpdates, false)
        XCTAssertEqual(dataStateLoaderMock.loadStateCallsCount, 1)
        XCTAssertEqual(dataStateLoaderMock.loadStateReceivedArguments?.paymentFlow, paymentFlow)
        XCTAssertEqual(savedCardMock.updatePresentationStateCallsCount, 1)
        XCTAssertEqual(savedCardMock.updatePresentationStateReceivedArguments, cards)
        XCTAssertEqual(payButtonMock.presentationState, .sbp)
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, true)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 1)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
    }

    func test_viewDidLoad_when_primaryPaymentMethodCard_success() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let sbpPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(
            primaryPaymentMethod: sbpPaymentMethod,
            otherPaymentMethods: [],
            cards: nil
        )
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.presentationState = .selected(card: .fake())
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = true
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state, MainFormState.processing.rawValue)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.animatePullableContainerUpdates, false)
        XCTAssertEqual(dataStateLoaderMock.loadStateCallsCount, 1)
        XCTAssertEqual(dataStateLoaderMock.loadStateReceivedArguments?.paymentFlow, paymentFlow)
        XCTAssertEqual(savedCardMock.updatePresentationStateCallsCount, 1)
        XCTAssertEqual(savedCardMock.updatePresentationStateReceivedArguments, [])
        XCTAssertEqual(payButtonMock.presentationState, .pay)
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 1)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
    }

    func test_viewDidLoad_when_primaryPaymentMethodCard_failure() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        dataStateLoaderMock.loadStateCompletionClosureInput = .failure(error)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 2)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].state, MainFormState.processing.rawValue)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[0].animatePullableContainerUpdates, false)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].state, MainFormState.somethingWentWrong.rawValue)
        XCTAssertEqual(viewMock.showCommonSheetReceivedInvocations[1].animatePullableContainerUpdates, true)
        XCTAssertEqual(dataStateLoaderMock.loadStateCallsCount, 1)
        XCTAssertEqual(dataStateLoaderMock.loadStateReceivedArguments?.paymentFlow, paymentFlow)
    }

//    func viewWasClosed() {
//        moduleCompletion?(moduleResult)
//        moduleCompletion = nil
//    }
//
//    func numberOfRows() -> Int {
//        cellTypes.count
//    }
//
//    func cellType(at indexPath: IndexPath) -> MainFormCellType {
//        cellTypes[indexPath.row]
//    }

    func test_didSelectRow_rowWithOtherPaymentMethodCard() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let dataState = MainFormDataState.any()
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let modifiedPaymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState)
        sut.viewDidLoad()

        let indexPath = IndexPath(row: 3, section: 0)

        // when
        sut.didSelectRow(at: indexPath)

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentReceivedArguments?.paymentFlow, modifiedPaymentFlow)
        XCTAssertEqual(routerMock.openCardPaymentReceivedArguments?.cards, dataState.cards)
    }

    func test_didSelectRow_rowWithOtherPaymentMethodSbp() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let dataState = MainFormDataState.any(otherPaymentMethods: [.sbp])
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let modifiedPaymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState).withSBPAnalytics()
        sut.viewDidLoad()

        let indexPath = IndexPath(row: 3, section: 0)

        // when
        sut.didSelectRow(at: indexPath)

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(routerMock.openSBPCallsCount, 1)
        XCTAssertEqual(routerMock.openSBPReceivedArguments?.paymentFlow, modifiedPaymentFlow)
        XCTAssertEqual(routerMock.openSBPReceivedArguments?.banks, dataState.sbpBanks)
    }

    func test_didSelectRow_rowWithOtherPaymentMethodTinkoffPay() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let tinkoffPayMethod = TinkoffPayMethod(version: "any version")
        let dataState = MainFormDataState.any(otherPaymentMethods: [.tinkoffPay(tinkoffPayMethod)])
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let modifiedPaymentFlow = paymentFlow
            .withPrimaryMethodAnalytics(dataState: dataState)
            .withTinkoffPayAnalytics()
        sut.viewDidLoad()
        viewMock.fullReset()

        let indexPath = IndexPath(row: 3, section: 0)

        // when
        sut.didSelectRow(at: indexPath)

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentCount, 1)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentParameters?.paymentFlow, modifiedPaymentFlow)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentParameters?.method, tinkoffPayMethod)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state, .tinkoffPay.processing)
    }

    func test_didSelectRow_anyOtherRow() {
        // given
        let tinkoffPayMethod = TinkoffPayMethod(version: "any version")
        let dataState = MainFormDataState.any(otherPaymentMethods: [.tinkoffPay(tinkoffPayMethod)])
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        sut.viewDidLoad()
        viewMock.fullReset()

        let indexPath1 = IndexPath(row: 0, section: 0)
        let indexPath2 = IndexPath(row: 1, section: 0)
        let indexPath3 = IndexPath(row: 2, section: 0)

        // when
        sut.didSelectRow(at: indexPath1)
        sut.didSelectRow(at: indexPath2)
        sut.didSelectRow(at: indexPath3)

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 0)
        XCTAssertEqual(routerMock.openCardPaymentCallsCount, 0)
        XCTAssertEqual(routerMock.openSBPCallsCount, 0)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentCount, 0)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 0)
    }
}

// MARK: - Private methods

extension MainFormPresenterTests {
    private func setupSut(
        cardScannerDelegate: CardScannerDelegateMock? = CardScannerDelegateMock(),
        paymentFlow: PaymentFlow = .fake(),
        configuration: MainFormUIConfiguration = MainFormUIConfiguration(orderDescription: "some text"),
        moduleCompletion: PaymentResultCompletion? = nil
    ) {
        viewMock = MainFormViewControllerMock()
        routerMock = MainFormRouterMock()
        mainFormOrderDetailsViewPresenterAssemblyMock = MainFormOrderDetailsViewPresenterAssemblyMock()
        savedCardViewPresenterAssemblyMock = SavedCardViewPresenterAssemblyMock()
        switchViewPresenterAssemblyMock = SwitchViewPresenterAssemblyMock()
        emailViewPresenterAssemblyMock = EmailViewPresenterAssemblyMock()
        payButtonViewPresenterAssemblyMock = PayButtonViewPresenterAssemblyMock()
        textAndImageHeaderViewPresenterAssemblyMock = TextAndImageHeaderViewPresenterAssemblyMock()
        dataStateLoaderMock = MainFormDataStateLoaderMock()
        paymentControllerMock = PaymentControllerMock()
        tinkoffPayControllerMock = TinkoffPayControllerMock()
        cardScannerDelegateMock = cardScannerDelegate

        sut = MainFormPresenter(
            router: routerMock,
            mainFormOrderDetailsViewPresenterAssembly: mainFormOrderDetailsViewPresenterAssemblyMock,
            savedCardViewPresenterAssembly: savedCardViewPresenterAssemblyMock,
            switchViewPresenterAssembly: switchViewPresenterAssemblyMock,
            emailViewPresenterAssembly: emailViewPresenterAssemblyMock,
            payButtonViewPresenterAssembly: payButtonViewPresenterAssemblyMock,
            textAndImageHeaderViewPresenterAssembly: textAndImageHeaderViewPresenterAssemblyMock,
            dataStateLoader: dataStateLoaderMock,
            paymentController: paymentControllerMock,
            tinkoffPayController: tinkoffPayControllerMock,
            paymentFlow: paymentFlow,
            configuration: configuration,
            cardScannerDelegate: cardScannerDelegateMock,
            moduleCompletion: moduleCompletion
        )

        sut.view = viewMock
    }
}

// MARK: - Helpers

extension MainFormDataState {
    static func any(
        primaryPaymentMethod: MainFormPaymentMethod = .sbp,
        otherPaymentMethods: [MainFormPaymentMethod] = [.card],
        cards: [PaymentCard]? = .fake()
    ) -> MainFormDataState {
        MainFormDataState(
            primaryPaymentMethod: primaryPaymentMethod,
            otherPaymentMethods: otherPaymentMethods,
            cards: cards,
            sbpBanks: nil
        )
    }
}
