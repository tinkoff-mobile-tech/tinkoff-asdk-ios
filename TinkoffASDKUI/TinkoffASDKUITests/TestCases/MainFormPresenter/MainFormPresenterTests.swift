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

    func test_commonSheetViewDidTapPrimaryButton_when_presentationState_payMethodsPresenting() throws {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        routerMock.openTinkoffPayLandingCompletionShouldCalls = true

        let url = try XCTUnwrap(URL(string: "https://www.tinkoff.ru"))
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        sut.tinkoffPayController(
            tinkoffPayControllerMock,
            completedDueToInabilityToOpenTinkoffPay: url,
            error: error
        )

        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 0)
        XCTAssertEqual(payButtonMock.stopLoadingCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapPrimaryButton_when_presentationState_loading() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 0)
        XCTAssertEqual(payButtonMock.stopLoadingCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapPrimaryButton_when_presentationState_tinkoffPayProcessing() throws {
        // given
        let tinkoffPayMethod = TinkoffPayMethod(version: "any version")
        let dataState = MainFormDataState.any(otherPaymentMethods: [.tinkoffPay(tinkoffPayMethod)])
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let indexPath = IndexPath(row: 3, section: 0)
        sut.viewDidLoad()
        sut.didSelectRow(at: indexPath)
        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 0)
        XCTAssertEqual(payButtonMock.stopLoadingCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapPrimaryButton_when_presentationState_paid() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        sut.paymentController(
            paymentControllerMock,
            didFinishPayment: PaymentProcessMock(),
            with: .fake(),
            cardId: nil,
            rebillId: nil
        )

        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
        XCTAssertEqual(payButtonMock.stopLoadingCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapPrimaryButton_when_presentationState_unrecoverableFailure() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        dataStateLoaderMock.loadStateCompletionClosureInput = .failure(error)

        sut.viewDidLoad()
        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
        XCTAssertEqual(payButtonMock.stopLoadingCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapPrimaryButton_when_presentationState_recoverableFailure() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        sut.paymentController(paymentControllerMock, didFailed: error, cardId: nil, rebillId: nil)
        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 0)
        XCTAssertEqual(payButtonMock.stopLoadingCallsCount, 1)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
    }

    func test_commonSheetViewDidTapSecondaryButton_when_presentationState_payMethodsPresenting() throws {
        // given
        routerMock.openTinkoffPayLandingCompletionShouldCalls = true

        let url = try XCTUnwrap(URL(string: "https://www.tinkoff.ru"))
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        sut.tinkoffPayController(
            tinkoffPayControllerMock,
            completedDueToInabilityToOpenTinkoffPay: url,
            error: error
        )

        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapSecondaryButton_when_presentationState_loading() {
        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapSecondaryButton_when_presentationState_paid() {
        // given
        sut.paymentController(
            paymentControllerMock,
            didFinishPayment: PaymentProcessMock(),
            with: .fake(),
            cardId: nil,
            rebillId: nil
        )

        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapSecondaryButton_when_presentationState_unrecoverableFailure() {
        // given
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        dataStateLoaderMock.loadStateCompletionClosureInput = .failure(error)

        sut.viewDidLoad()
        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapSecondaryButton_when_presentationState_recoverableFailure() {
        // given
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        sut.paymentController(paymentControllerMock, didFailed: error, cardId: nil, rebillId: nil)
        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
    }

    func test_commonSheetViewDidTapSecondaryButton_when_presentationState_tinkoffPayProcessing() {
        // given
        let tinkoffPayMethod = TinkoffPayMethod(version: "any version")
        let dataState = MainFormDataState.any(otherPaymentMethods: [.tinkoffPay(tinkoffPayMethod)])
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let indexPath = IndexPath(row: 3, section: 0)
        sut.viewDidLoad()
        sut.didSelectRow(at: indexPath)
        viewMock.fullReset()

        // when
        sut.commonSheetViewDidTapSecondaryButton()

        // then
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
    }

    func test_savedCardPresenter_didRequestReplacementFor_with_cards() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let sbpPaymentMethod = MainFormPaymentMethod.sbp
        let dataState = MainFormDataState.any(primaryPaymentMethod: sbpPaymentMethod)
        let cards = dataState.cards
        let expectedPaymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState)

        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        sut.viewDidLoad()

        let paymentCard = PaymentCard.fake()

        // when
        sut.savedCardPresenter(.any, didRequestReplacementFor: paymentCard)

        // then
        XCTAssertEqual(routerMock.openCardPaymentListCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.paymentFlow, expectedPaymentFlow)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.cards, cards)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.selectedCard, paymentCard)
    }

    func test_savedCardPresenter_didRequestReplacementFor_with_noCards() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let sbpPaymentMethod = MainFormPaymentMethod.sbp
        let dataState = MainFormDataState.any(primaryPaymentMethod: sbpPaymentMethod, cards: nil)
        let expectedPaymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        sut.viewDidLoad()

        let paymentCard = PaymentCard.fake()

        // when
        sut.savedCardPresenter(.any, didRequestReplacementFor: paymentCard)

        // then
        XCTAssertEqual(routerMock.openCardPaymentListCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.paymentFlow, expectedPaymentFlow)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.cards, [])
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.selectedCard, paymentCard)
    }

    func test_savedCardPresenter_didUpdateCVC() {
        // given
        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod, cards: [.fake()])
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        sut.viewDidLoad()
        viewMock.fullReset()
        payButtonMock.fullReset()

        // when
        sut.savedCardPresenter(.any, didUpdateCVC: "111", isValid: false)

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_getReceiptSwitchDidChange_to_on() {
        // given
        let isOn = true

        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.presentationState = .selected(card: .fake())
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        sut.viewDidLoad()
        payButtonMock.fullReset()

        let expectedIndexPath = IndexPath(row: 3, section: 0)

        // when
        sut.getReceiptSwitch(didChange: isOn)

        // then
        XCTAssertEqual(viewMock.insertRowsCallsCount, 1)
        XCTAssertEqual(viewMock.insertRowsReceivedArguments, [expectedIndexPath])
        XCTAssertEqual(viewMock.deleteRowsCallsCount, 0)
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_getReceiptSwitchDidChange_to_off() {
        // given
        let isOn = false

        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.presentationState = .selected(card: .fake())
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = true
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        sut.viewDidLoad()
        payButtonMock.fullReset()

        let expectedIndexPath = IndexPath(row: 3, section: 0)

        // when
        sut.getReceiptSwitch(didChange: isOn)

        // then
        XCTAssertEqual(viewMock.insertRowsCallsCount, 0)
        XCTAssertEqual(viewMock.deleteRowsCallsCount, 1)
        XCTAssertEqual(viewMock.deleteRowsReceivedArguments, [expectedIndexPath])
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_getReceiptSwitchDidChange_when_no_switchCell() {
        // given
        let isOn = true

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.getReceiptSwitch(didChange: isOn)

        // then
        XCTAssertEqual(viewMock.insertRowsCallsCount, 0)
        XCTAssertEqual(viewMock.deleteRowsCallsCount, 0)
        XCTAssertEqual(payButtonMock.setCallsCount, 0)
    }

    func test_payButtonViewTapped_when_primaryPaymentMethodCard_and_presentationStateSelected_switchIsOff() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let cardId = "12345678"
        let cvc = "111"
        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.cardId = cardId
        savedCardMock.cvc = cvc
        savedCardMock.presentationState = .selected(card: .fake())
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let expectedPaymentFlow = paymentFlow
            .replacing(customerEmail: nil)
            .withPrimaryMethodAnalytics(dataState: dataState)
            .withSavedCardAnalytics()

        sut.viewDidLoad()
        viewMock.fullReset()

        let paymentSource = PaymentSourceData.savedCard(cardId: cardId, cvv: cvc)

        // when
        sut.payButtonViewTapped(PayButtonViewOutputMock())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentFlow, expectedPaymentFlow)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, paymentSource)
    }

    func test_payButtonViewTapped_when_primaryPaymentMethodCard_and_presentationStateSelected_switchIsOn() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let cardId = "12345678"
        let cvc = "111"
        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.cardId = cardId
        savedCardMock.cvc = cvc
        savedCardMock.presentationState = .selected(card: .fake())
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = true
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        let email = "some@some.some"
        let emailMock = EmailViewOutputMock()
        emailViewPresenterAssemblyMock.buildReturnValue = emailMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let expectedPaymentFlow = paymentFlow
            .replacing(customerEmail: email)
            .withPrimaryMethodAnalytics(dataState: dataState)
            .withSavedCardAnalytics()

        sut.viewDidLoad()
        viewMock.fullReset()

        let paymentSource = PaymentSourceData.savedCard(cardId: cardId, cvv: cvc)

        // when
        sut.payButtonViewTapped(PayButtonViewOutputMock())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentFlow, expectedPaymentFlow)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, paymentSource)
    }

    func test_payButtonViewTapped_when_primaryPaymentMethodCard_and_cardId_with_cvc_nil() {
        // given
        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.presentationState = .selected(card: .fake())
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        sut.viewDidLoad()
        viewMock.fullReset()

        // when
        sut.payButtonViewTapped(PayButtonViewOutputMock())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 0)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 0)
    }

    func test_payButtonViewTapped_when_primaryPaymentMethodCard_and_presentationStateNotSelected() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let cardPaymentMethod = MainFormPaymentMethod.card
        let dataState = MainFormDataState.any(primaryPaymentMethod: cardPaymentMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let modifiedPaymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState)

        sut.viewDidLoad()
        viewMock.fullReset()

        // when
        sut.payButtonViewTapped(PayButtonViewOutputMock())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentReceivedArguments?.paymentFlow, modifiedPaymentFlow)
        XCTAssertEqual(routerMock.openCardPaymentReceivedArguments?.cards, dataState.cards)
    }

    func test_payButtonViewTapped_when_primaryPaymentMethodTinkoffPay() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let tinkoffPayMethod = TinkoffPayMethod(version: "any version")
        let payMethod = MainFormPaymentMethod.tinkoffPay(tinkoffPayMethod)
        let dataState = MainFormDataState.any(primaryPaymentMethod: payMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let modifiedPaymentFlow = paymentFlow
            .withPrimaryMethodAnalytics(dataState: dataState)
            .withTinkoffPayAnalytics()

        sut.viewDidLoad()
        viewMock.fullReset()

        // when
        sut.payButtonViewTapped(PayButtonViewOutputMock())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentCount, 1)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentParameters?.paymentFlow, modifiedPaymentFlow)
        XCTAssertEqual(tinkoffPayControllerMock.invokedPerformPaymentParameters?.method, tinkoffPayMethod)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state, .tinkoffPay.processing)
    }

    func test_payButtonViewTapped_when_primaryPaymentMethodSbp() {
        // given
        let paymentFlow = PaymentFlow.fake()
        setupSut(paymentFlow: paymentFlow)

        let sbpPayMethod = MainFormPaymentMethod.sbp
        let dataState = MainFormDataState.any(primaryPaymentMethod: sbpPayMethod)
        dataStateLoaderMock.loadStateCompletionClosureInput = .success(dataState)

        let modifiedPaymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState).withSBPAnalytics()

        sut.viewDidLoad()
        viewMock.fullReset()

        // when
        sut.payButtonViewTapped(PayButtonViewOutputMock())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(routerMock.openSBPCallsCount, 1)
        XCTAssertEqual(routerMock.openSBPReceivedArguments?.paymentFlow, modifiedPaymentFlow)
        XCTAssertEqual(routerMock.openSBPReceivedArguments?.banks, dataState.sbpBanks)
    }

    func test_emailTextField_didChangeEmail() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.emailTextField(.fake(), didChangeEmail: "some@some.some", isValid: false)

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, true)
    }

    func test_paymentControllerDidFinishPayment() {
        // when
        sut.paymentController(
            paymentControllerMock,
            didFinishPayment: PaymentProcessMock(),
            with: .fake(),
            cardId: nil,
            rebillId: nil
        )

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state, MainFormState.paid.rawValue)
    }

    func test_paymentControllerDidFailed() {
        // given
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)

        // when
        sut.paymentController(paymentControllerMock, didFailed: error, cardId: nil, rebillId: nil)

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state, MainFormState.paymentFailed.rawValue)
    }

    func test_paymentControllerPaymentWasCancelled() {
        // when
        sut.paymentController(
            paymentControllerMock,
            paymentWasCancelled: PaymentProcessMock(),
            cardId: nil,
            rebillId: nil
        )

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
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

extension SavedCardViewPresenter {
    static var any: SavedCardViewPresenter {
        SavedCardViewPresenter(
            validator: CardRequisitesValidatorMock(),
            paymentSystemResolver: PaymentSystemResolverMock(),
            bankResolver: BankResolverMock(),
            output: SavedCardViewPresenterOutputMock()
        )
    }
}
