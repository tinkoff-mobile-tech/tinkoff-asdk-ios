//
//  RecurrentPaymentPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 05.06.2023.
//

import XCTest

@testable import TinkoffASDKCore
@testable import TinkoffASDKUI

final class RecurrentPaymentPresenterTests: BaseTestCase {

    var sut: RecurrentPaymentPresenter!

    // Mocksx`

    var viewMock: RecurrentPaymentViewInputMock!
    var savedCardViewPresenterAssemblyMock: SavedCardViewPresenterAssemblyMock!
    var payButtonViewPresenterAssemblyMock: PayButtonViewPresenterAssemblyMock!
    var paymentControllerMock: PaymentControllerMock!
    var cardsControllerMock: CardsControllerMock!
    var mainDispatchQueueMock: DispatchQueueMock!
    var failureDelegateMock: RecurrentPaymentFailiureDelegateMock!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        savedCardViewPresenterAssemblyMock = nil
        payButtonViewPresenterAssemblyMock = nil
        paymentControllerMock = nil
        cardsControllerMock = nil
        mainDispatchQueueMock = nil
        failureDelegateMock = nil

        sut = nil

        DispatchQueueMock.performOnMainCallsCount = 0

        super.tearDown()
    }

    // MARK: - Tests

    func test_viewDidLoad() {
        // given
        let paymentFlow = PaymentFlow.fake()
        let rebillId = "123456"
        let paymentSource = PaymentSourceData.parentPayment(rebuidId: rebillId)

        setupSut(paymentFlow: paymentFlow, rebillId: rebillId)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .processing)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.animatePullableContainerUpdates, false)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, paymentSource)
    }

    func test_viewWasClosed_succeeded() {
        // given
        var expectedPaymentResult: PaymentResult?
        let moduleCompletion: PaymentResultCompletion = { result in
            expectedPaymentResult = result
        }
        setupSut(moduleCompletion: moduleCompletion)

        let payload = GetPaymentStatePayload.fake()
        let paymentInfo = payload.toPaymentInfo()

        sut.paymentController(
            PaymentControllerMock(),
            didFinishPayment: PaymentProcessMock(),
            with: payload,
            cardId: nil,
            rebillId: nil
        )

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(expectedPaymentResult, .succeeded(paymentInfo))
    }

    func test_viewWasClosed_failed() {
        // given
        var expectedPaymentResult: PaymentResult?
        let moduleCompletion: PaymentResultCompletion = { result in
            expectedPaymentResult = result
        }
        setupSut(moduleCompletion: moduleCompletion)

        let error = NSError(domain: "error", code: 123456)
        sut.paymentController(
            PaymentControllerMock(),
            didFailed: error,
            cardId: nil,
            rebillId: nil
        )

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(expectedPaymentResult, .failed(error))
    }

    func test_viewWasClosed_cancelled() {
        // given
        var expectedPaymentResult: PaymentResult?
        let moduleCompletion: PaymentResultCompletion = { result in
            expectedPaymentResult = result
        }
        setupSut(moduleCompletion: moduleCompletion)

        // when
        sut.viewWasClosed()

        // then
        XCTAssertEqual(expectedPaymentResult, .cancelled())
    }

    func test_numberOfRows_0() {
        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, 0)
    }

    func test_numberOfRows_2() {
        // given
        let error = NSError(domain: "error", code: 123456)

        let parentId: Int64 = 123
        let savedCard = PaymentCard(
            pan: "427432",
            cardId: "124913",
            status: .active,
            parentPaymentId: parentId,
            expDate: "0929"
        )
        var cards = [PaymentCard].fake()
        cards.insert(savedCard, at: 0)

        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.success(cards))
        }

        sut.paymentController(
            PaymentControllerMock(),
            shouldRepeatWithRebillId: String(parentId),
            failedPaymentProcess: PaymentProcessMock(),
            additionalData: [:],
            error: error
        )

        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, 2)
    }

    func test_cellTypeAtIndexPath() {
        // given
        let error = NSError(domain: "error", code: 123456)

        let parentId: Int64 = 123
        let savedCard = PaymentCard(
            pan: "427432",
            cardId: "124913",
            status: .active,
            parentPaymentId: parentId,
            expDate: "0929"
        )
        var cards = [PaymentCard].fake()
        cards.insert(savedCard, at: 0)

        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.success(cards))
        }

        sut.paymentController(
            PaymentControllerMock(),
            shouldRepeatWithRebillId: String(parentId),
            failedPaymentProcess: PaymentProcessMock(),
            additionalData: [:],
            error: error
        )

        // when
        let cellType1 = sut.cellType(at: IndexPath(row: 0, section: 0))
        let cellType2 = sut.cellType(at: IndexPath(row: 1, section: 0))

        // then
        XCTAssertEqual(cellType1, .savedCard(SavedCardViewOutputMock()))
        XCTAssertEqual(cellType2, .payButton(PayButtonViewOutputMock()))
    }
    
    func test_commonSheetViewDidTapPrimaryButton() {
        // when
        sut.commonSheetViewDidTapPrimaryButton()

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
    }

    func test_savedCardPresenter_didUpdateCVC_when_valid() {
        // given
        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.underlyingIsValid = true
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.savedCardPresenter(.fake(), didUpdateCVC: "", isValid: false)

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedArguments, true)
    }

    func test_savedCardPresenter_didUpdateCVC_when_notValid() {
        // given
        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.underlyingIsValid = false
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.savedCardPresenter(.fake(), didUpdateCVC: "", isValid: false)

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_payButtonViewTapped_when_paymentFlowFull() {
        // given
        let paymentFlow = PaymentFlow.fullRandom
        let cardId = "1234567"
        let cvc = "111"
        setupSut(paymentFlow: paymentFlow)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.cardId = cardId
        savedCardMock.cvc = cvc
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let expectedSource = PaymentSourceData.savedCard(cardId: cardId, cvv: cvc)

        // when
        sut.payButtonViewTapped(FakePayButtonViewPresenterInput())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentFlow, paymentFlow)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, expectedSource)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
    }

    func test_payButtonViewTapped_when_paymentFlowFinish_and_failureDelegateSuccess() {
        // given
        let paymentFlow = PaymentFlow.finishAny

        let cardId = "1234567"
        let cvc = "111"
        setupSut(paymentFlow: paymentFlow)

        let paymentId = "112233"
        failureDelegateMock.recurrentPaymentNeedRepeatInitCompletionClosureInput = .success(paymentId)

        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.cardId = cardId
        savedCardMock.cvc = cvc
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let expectedSource = PaymentSourceData.savedCard(cardId: cardId, cvv: cvc)

        // when
        sut.payButtonViewTapped(FakePayButtonViewPresenterInput())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(failureDelegateMock.recurrentPaymentNeedRepeatInitCallsCount, 1)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentReceivedArguments?.paymentSource, expectedSource)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
    }

    func test_payButtonViewTapped_when_paymentFlowFinish_and_failureDelegateError() {
        // given
        let paymentFlow = PaymentFlow.finishAny

        let cardId = "1234567"
        let cvc = "111"
        setupSut(paymentFlow: paymentFlow)

        let error = NSError(domain: "error", code: 123456)
        failureDelegateMock.recurrentPaymentNeedRepeatInitCompletionClosureInput = .failure(error)

        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.cardId = cardId
        savedCardMock.cvc = cvc
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.payButtonViewTapped(FakePayButtonViewPresenterInput())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(failureDelegateMock.recurrentPaymentNeedRepeatInitCallsCount, 1)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 0)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .failed)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
    }

    func test_payButtonViewTapped_when_noCardIdAndCvc() {
        // given
        let error = NSError(domain: "error", code: 123456)
        failureDelegateMock.recurrentPaymentNeedRepeatInitCompletionClosureInput = .failure(error)

        DispatchQueueMock.performOnMainBlockClosureShouldCalls = true

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.payButtonViewTapped(FakePayButtonViewPresenterInput())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(failureDelegateMock.recurrentPaymentNeedRepeatInitCallsCount, 0)
        XCTAssertEqual(DispatchQueueMock.performOnMainCallsCount, 0)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 0)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 0)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 0)
    }

    func test_paymentController_didFinishPayment() {
        // when
        sut.paymentController(
            PaymentControllerMock(),
            didFinishPayment: PaymentProcessMock(),
            with: .fake(),
            cardId: nil,
            rebillId: nil
        )

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .succeeded)
    }

    func test_paymentController_didFailed() {
        // given
        let error = NSError(domain: "error", code: 123456)

        // when
        sut.paymentController(
            PaymentControllerMock(),
            didFailed: error,
            cardId: nil,
            rebillId: nil
        )

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .failed)
    }

    func test_paymentController_paymentWasCancelled() {
        // when
        sut.paymentController(
            PaymentControllerMock(),
            paymentWasCancelled: PaymentProcessMock(),
            cardId: nil,
            rebillId: nil
        )

        // then
        XCTAssertEqual(viewMock.closeViewCallsCount, 1)
    }

    func test_paymentController_shouldRepeatWithRebillId_when_cardsControllerExist_and_success() {
        // given
        let error = NSError(domain: "error", code: 123456)

        let parentId: Int64 = 123
        let savedCard = PaymentCard(
            pan: "427432",
            cardId: "124913",
            status: .active,
            parentPaymentId: parentId,
            expDate: "0929"
        )
        var cards = [PaymentCard].fake()
        cards.insert(savedCard, at: 0)

        let savedCardMock = SavedCardViewOutputMock()
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.success(cards))
        }

        // when
        sut.paymentController(
            PaymentControllerMock(),
            shouldRepeatWithRebillId: String(parentId),
            failedPaymentProcess: PaymentProcessMock(),
            additionalData: [:],
            error: error
        )

        // then
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(savedCardMock.presentationState, .selected(card: savedCard, showChangeDescription: false))
        XCTAssertEqual(viewMock.reloadDataCallsCount, 1)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 1)
        XCTAssertEqual(savedCardMock.activateCVCFieldCallsCount, 1)
    }

    func test_paymentController_shouldRepeatWithRebillId_when_cardsControllerExist_and_success_with_noSavedCard() {
        // given
        let error = NSError(domain: "error", code: 123456)

        let parentId: Int64 = 111111
        let cards = [PaymentCard].fake()

        let savedCardMock = SavedCardViewOutputMock()
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.success(cards))
        }

        // when
        sut.paymentController(
            PaymentControllerMock(),
            shouldRepeatWithRebillId: String(parentId),
            failedPaymentProcess: PaymentProcessMock(),
            additionalData: [:],
            error: error
        )

        // then
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .failed)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
        XCTAssertEqual(savedCardMock.activateCVCFieldCallsCount, 0)
    }

    func test_paymentController_shouldRepeatWithRebillId_when_cardsControllerExist_and_failure() {
        // given
        let error = NSError(domain: "error", code: 123456)

        let parentId: Int64 = 111111

        let savedCardMock = SavedCardViewOutputMock()
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.failure(error))
        }

        // when
        sut.paymentController(
            PaymentControllerMock(),
            shouldRepeatWithRebillId: String(parentId),
            failedPaymentProcess: PaymentProcessMock(),
            additionalData: [:],
            error: error
        )

        // then
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .failed)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
        XCTAssertEqual(savedCardMock.activateCVCFieldCallsCount, 0)
    }

    func test_paymentController_shouldRepeatWithRebillId_when_cardsControllerNotExist() {
        // given
        setupSut(cardsController: nil)

        let error = NSError(domain: "error", code: 123456)

        let parentId: Int64 = 111111

        let savedCardMock = SavedCardViewOutputMock()
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        // when
        sut.paymentController(
            PaymentControllerMock(),
            shouldRepeatWithRebillId: String(parentId),
            failedPaymentProcess: PaymentProcessMock(),
            additionalData: [:],
            error: error
        )

        // then
        XCTAssertEqual(viewMock.showCommonSheetCallsCount, 1)
        XCTAssertEqual(viewMock.showCommonSheetReceivedArguments?.state.status, .failed)
        XCTAssertEqual(viewMock.reloadDataCallsCount, 0)
        XCTAssertEqual(viewMock.hideCommonSheetCallsCount, 0)
        XCTAssertEqual(savedCardMock.activateCVCFieldCallsCount, 0)
    }
}

// MARK: - Private methods

extension RecurrentPaymentPresenterTests {
    private func setupSut(
        cardsController: CardsControllerMock? = CardsControllerMock(),
        paymentFlow: PaymentFlow = .fake(),
        rebillId: String = "123456",
        amount: Int64 = 100,
        moduleCompletion: PaymentResultCompletion? = nil
    ) {
        viewMock = RecurrentPaymentViewInputMock()
        savedCardViewPresenterAssemblyMock = SavedCardViewPresenterAssemblyMock()
        payButtonViewPresenterAssemblyMock = PayButtonViewPresenterAssemblyMock()
        paymentControllerMock = PaymentControllerMock()
        cardsControllerMock = cardsController
        mainDispatchQueueMock = DispatchQueueMock()
        failureDelegateMock = RecurrentPaymentFailiureDelegateMock()

        sut = RecurrentPaymentPresenter(
            savedCardViewPresenterAssembly: savedCardViewPresenterAssemblyMock,
            payButtonViewPresenterAssembly: payButtonViewPresenterAssemblyMock,
            paymentController: paymentControllerMock,
            cardsController: cardsControllerMock,
            paymentFlow: paymentFlow,
            mainDispatchQueue: mainDispatchQueueMock,
            rebillId: rebillId,
            amount: amount,
            failureDelegate: failureDelegateMock,
            moduleCompletion: moduleCompletion
        )
        sut.view = viewMock
    }
}
