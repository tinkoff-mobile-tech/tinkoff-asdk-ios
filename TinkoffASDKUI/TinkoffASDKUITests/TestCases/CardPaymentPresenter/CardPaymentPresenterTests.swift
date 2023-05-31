//
//  CardPaymentPresenterTests.swift
//  TinkoffASDKUI-Unit-Tests
//
//  Created by Aleksandr Pravosudov on 19.05.2023.
//

import Foundation
import XCTest

import TinkoffASDKCore
@testable import TinkoffASDKUI

final class CardPaymentPresenterTests: BaseTestCase {

    var sut: CardPaymentPresenter!

    // MARK: Mocks

    var viewMock: CardPaymentViewControllerInputMock!
    var routerMock: CardPaymentRouterMock!
    var outputMock: CardPaymentPresenterModuleOutputMock!
    var savedCardViewPresenterAssemblyMock: SavedCardViewPresenterAssemblyMock!
    var cardFieldPresenterAssemblyMock: CardFieldPresenterAssemblyMock!
    var switchViewPresenterAssemblyMock: SwitchViewPresenterAssemblyMock!
    var emailViewPresenterAssemblyMock: EmailViewPresenterAssemblyMock!
    var payButtonViewPresenterAssemblyMock: PayButtonViewPresenterAssemblyMock!
    var cardListOutputMock: CardListPresenterOutputMock!
    var cardsControllerMock: CardsControllerMock!
    var paymentControllerMock: PaymentControllerMock!
    var mainDispatchQueueMock: DispatchQueueMock!

    // MARK: Setup

    override func setUp() {
        super.setUp()

        setupSut()
    }

    override func tearDown() {
        viewMock = nil
        routerMock = nil
        outputMock = nil
        savedCardViewPresenterAssemblyMock = nil
        cardFieldPresenterAssemblyMock = nil
        switchViewPresenterAssemblyMock = nil
        emailViewPresenterAssemblyMock = nil
        payButtonViewPresenterAssemblyMock = nil
        cardListOutputMock = nil
        cardsControllerMock = nil
        paymentControllerMock = nil
        mainDispatchQueueMock = nil

        sut = nil

        super.tearDown()
    }

    // MARK: Tests

    func test_viewDidLoad_with_initialActiveCards() {
        // given
        setupSut(activeCards: createActiveCardsArray())

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }

    func test_viewDidLoad_with_initialActiveCardsNil_and_cardsControllerNil() {
        // given
        setupSut(cardsController: nil, activeCards: nil)

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.showActivityIndicatorReceivedArguments, .xlYellow)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }

    func test_viewDidLoad_with_initialActiveCardsNil_success() {
        // given
        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.success(self.createActiveCardsArray()))
        }
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.showActivityIndicatorReceivedArguments, .xlYellow)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.hideActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }

    func test_viewDidLoad_with_initialActiveCardsNil_failure() {
        // given
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)
        cardsControllerMock.getActiveCardsStub = { completion in
            completion(.failure(error))
        }
        mainDispatchQueueMock.asyncWorkShouldCalls = true

        // when
        sut.viewDidLoad()

        // then
        XCTAssertEqual(viewMock.showActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.showActivityIndicatorReceivedArguments, .xlYellow)
        XCTAssertEqual(cardsControllerMock.getActiveCardsCallsCount, 1)
        XCTAssertEqual(mainDispatchQueueMock.asyncCallsCount, 1)
        XCTAssertEqual(viewMock.hideActivityIndicatorCallsCount, 1)
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
    }

    func test_cellType_when_initialActiveCards() {
        // given
        setupSut(activeCards: createActiveCardsArray())
        sut.viewDidLoad()

        // when
        let types = [0, 1, 2, 3].map { sut.cellType(for: $0) }

        // then
        types.enumerated().forEach { index, type in
            switch type {
            case .savedCard where index == 0: break
            case .getReceipt where index == 1: break
            case .emailField where index == 2: break
            case .payButton where index == 3: break
            default: XCTFail("Wrong types of presenters")
            }
        }
    }

    func test_cellType_when_initialActiveCards_with_userEmailNil() {
        // given
        setupSut(activeCards: createActiveCardsArray(), paymentFlow: .fake())
        sut.viewDidLoad()

        // when
        let types = [0, 1, 2].map { sut.cellType(for: $0) }

        // then
        types.enumerated().forEach { index, type in
            switch type {
            case .savedCard where index == 0: break
            case .getReceipt where index == 1: break
            case .payButton where index == 2: break
            default: XCTFail("Wrong types of presenters")
            }
        }
    }

    func test_cellType_when_initialActiveCardsEmpty() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())
        sut.viewDidLoad()

        // when
        let types = [0, 1, 2, 3].map { sut.cellType(for: $0) }

        // then
        types.enumerated().forEach { index, type in
            switch type {
            case .cardField where index == 0: break
            case .getReceipt where index == 1: break
            case .emailField where index == 2: break
            case .payButton where index == 3: break
            default: XCTFail("Wrong types of presenters")
            }
        }
    }

    func test_closeButtonPressed() {
        // given
        sut.viewDidAppear()

        // when
        sut.closeButtonPressed()

        // then
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
    }

    func test_numberOfRows_with_activeCards_with_userEmailNil() {
        // given
        setupSut(activeCards: createActiveCardsArray(), paymentFlow: .fake())
        sut.viewDidLoad()

        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, 3)
    }

    func test_numberOfRows_with_activeCards() {
        // given
        setupSut(activeCards: createActiveCardsArray())
        sut.viewDidLoad()

        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, 4)
    }

    func test_numberOfRows_with_emptyActiveCards() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())
        sut.viewDidLoad()

        // when
        let numberOfRows = sut.numberOfRows()

        // then
        XCTAssertEqual(numberOfRows, 4)
    }

    func test_switchAction_false() {
        // given
        setupSut(activeCards: createActiveCardsArray())

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let cardFieldMock = CardFieldViewOutputMock()
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldMock

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.underlyingIsValid = true
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        sut.viewDidLoad()

        payButtonMock.setCallsCount = 0

        // when
        switchViewPresenterAssemblyMock.buildReceivedArguments?.actionBlock?(false)

        // then
        XCTAssertEqual(viewMock.deleteCallsCount, 1)
        XCTAssertEqual(viewMock.deleteReceivedArguments, 2)
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, true)
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(cardFieldMock.validateWholeFormCallsCount, 1)
    }

    func test_switchAction_true() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let cardFieldMock = CardFieldViewOutputMock()
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldMock

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.underlyingIsValid = false
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = true
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        sut.viewDidLoad()

        payButtonMock.setCallsCount = 0

        // when
        switchViewPresenterAssemblyMock.buildReceivedArguments?.actionBlock?(true)

        // then
        XCTAssertEqual(viewMock.insertCallsCount, 1)
        XCTAssertEqual(viewMock.insertReceivedArguments, 2)
        XCTAssertEqual(payButtonMock.setCallsCount, 1)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(cardFieldMock.validateWholeFormCallsCount, 1)
    }

    func test_scanButtonPressed() {
        // given
        let cardNumber = "1234567812345678"
        let expiration = "2345"
        let cvc = "111"

        let cardFieldPresenter = CardFieldViewOutputMock()
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldPresenter
        routerMock.showCardScannerCompletionClosureInput = (cardNumber, expiration, cvc)

        // when
        sut.scanButtonPressed()

        // then
        XCTAssertEqual(routerMock.showCardScannerCallsCount, 1)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeCallsCount, 3)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeReceivedInvocations[0].0, .cardNumber)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeReceivedInvocations[0].1, cardNumber)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeReceivedInvocations[1].0, .expiration)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeReceivedInvocations[1].1, expiration)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeReceivedInvocations[2].0, .cvc)
        XCTAssertEqual(cardFieldPresenter.setTextFieldTypeReceivedInvocations[2].1, cvc)
    }

    func test_cardFieldValidationResultDidChange_allValid() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.cardFieldValidationResultDidChange(result: .allValid())

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedInvocations[1], true)
    }

    func test_cardFieldValidationResultDidChange_notValid() {
        // given
        setupSut(activeCards: createActiveCardsEmptyArray())

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.cardFieldValidationResultDidChange(result: .notValid())

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedInvocations[1], false)
    }

    func test_emailTextFieldDidBeginEditing() {
        // given
        let cardFieldPresenter = CardFieldViewOutputMock()
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldPresenter

        // when
        sut.emailTextFieldDidBeginEditing(.fake())

        // then
        XCTAssertEqual(cardFieldPresenter.validateWholeFormCallsCount, 1)
    }

    func test_emailTextFieldDidChangeEmail() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.emailTextField(.fake(), didChangeEmail: "", isValid: false)

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_emailTextFieldDidPressReturn() {
        // given
        let cardFieldPresenter = CardFieldViewOutputMock()
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldPresenter

        // when
        sut.emailTextFieldDidPressReturn(.fake())

        // then
        XCTAssertEqual(cardFieldPresenter.validateWholeFormCallsCount, 1)
    }

    func test_savedCardPresenterDidRequestReplacementFor() {
        // given
        let activeCards = createActiveCardsArray()
        let paymentFlow = PaymentFlow.fullRandom
        let paymentCard = PaymentCard.fake()
        let amount: Int64 = 234

        setupSut(activeCards: activeCards, paymentFlow: paymentFlow, amount: amount)

        // when
        sut.savedCardPresenter(.fake(), didRequestReplacementFor: paymentCard)

        // then
        XCTAssertEqual(routerMock.openCardPaymentListCallsCount, 1)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.paymentFlow, paymentFlow)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.amount, amount)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.cards, activeCards)
        XCTAssertEqual(routerMock.openCardPaymentListReceivedArguments?.selectedCard, paymentCard)
    }

    func test_savedCardPresenterDidUpdateCVC() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.savedCardPresenter(.fake(), didUpdateCVC: "", isValid: false)

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_payButtonViewTapped_when_activeCardsEmpty() {
        // given
        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let cardFieldPresenter = CardFieldViewOutputMock()
        cardFieldPresenter.underlyingCardNumber = "1234567812345678"
        cardFieldPresenter.underlyingExpiration = "1234"
        cardFieldPresenter.underlyingCvc = "111"
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldPresenter

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.payButtonViewTapped(FakePayButtonViewPresenterInput())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(viewMock.startIgnoringInteractionEventsCallsCount, 1)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
    }

    func test_payButtonViewTapped_when_activeCardsExists() {
        // given
        setupSut(activeCards: createActiveCardsArray())

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        let cardFieldPresenter = CardFieldViewOutputMock()
        cardFieldPresenter.underlyingCardNumber = "1234567812345678"
        cardFieldPresenter.underlyingExpiration = "1234"
        cardFieldPresenter.underlyingCvc = "111"
        cardFieldPresenterAssemblyMock.buildReturnValue = cardFieldPresenter

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = true
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        // when
        sut.payButtonViewTapped(FakePayButtonViewPresenterInput())

        // then
        XCTAssertEqual(viewMock.hideKeyboardCallsCount, 1)
        XCTAssertEqual(viewMock.startIgnoringInteractionEventsCallsCount, 1)
        XCTAssertEqual(payButtonMock.startLoadingCallsCount, 1)
        XCTAssertEqual(paymentControllerMock.performPaymentCallsCount, 1)
    }

    func test_cardListDidUpdate() {
        // given
        let cards = createActiveCardsArray()

        let savedCardMock = SavedCardViewOutputMock()
        savedCardMock.underlyingIsValid = false
        savedCardViewPresenterAssemblyMock.buildReturnValue = savedCardMock

        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.cardList(didUpdate: cards)

        // then
        XCTAssertEqual(viewMock.reloadTableViewCallsCount, 1)
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_cardListWillCloseAfterSelecting() {
        // given
        let switchMock = SwitchViewOutputMock()
        switchMock.underlyingIsOn = false
        switchViewPresenterAssemblyMock.buildReturnValue = switchMock

        let payButtonMock = PayButtonViewOutputMock()
        payButtonViewPresenterAssemblyMock.buildReturnValue = payButtonMock

        // when
        sut.cardList(willCloseAfterSelecting: .fake())

        // then
        XCTAssertEqual(payButtonMock.setCallsCount, 2)
        XCTAssertEqual(payButtonMock.setReceivedArguments, false)
    }

    func test_paymentControllerDidFinishPayment() {
        // given
        routerMock.closeScreenCompletionShouldCalls = true

        // when
        sut.paymentController(
            paymentControllerMock,
            didFinishPayment: PaymentProcessMock(),
            with: .fake(),
            cardId: "",
            rebillId: ""
        )

        // then
        XCTAssertEqual(viewMock.stopIgnoringInteractionEventsCallsCount, 1)
        XCTAssertEqual(outputMock.cardPaymentWillCloseAfterFinishedPaymentCallsCount, 1)
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
        XCTAssertEqual(outputMock.cardPaymentDidCloseAfterFinishedPaymentCallsCount, 1)
    }

    func test_paymentControllerPaymentWasCancelled() {
        // given
        routerMock.closeScreenCompletionShouldCalls = true

        // when
        sut.paymentController(
            paymentControllerMock,
            paymentWasCancelled: PaymentProcessMock(),
            cardId: "",
            rebillId: ""
        )

        // then
        XCTAssertEqual(viewMock.stopIgnoringInteractionEventsCallsCount, 1)
        XCTAssertEqual(outputMock.cardPaymentDidCloseAfterCancelledPaymentCallsCount, 1)
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
        XCTAssertEqual(outputMock.cardPaymentDidCloseAfterCancelledPaymentCallsCount, 1)
    }

    func test_paymentControllerDidFailed() {
        // given
        routerMock.closeScreenCompletionShouldCalls = true
        let error = NSError(domain: "error", code: NSURLErrorNotConnectedToInternet)

        // when
        sut.paymentController(
            paymentControllerMock,
            didFailed: error,
            cardId: "",
            rebillId: ""
        )

        // then
        XCTAssertEqual(viewMock.stopIgnoringInteractionEventsCallsCount, 1)
        XCTAssertEqual(outputMock.cardPaymentWillCloseAfterFailedPaymentCallsCount, 1)
        XCTAssertEqual(routerMock.closeScreenCallsCount, 1)
        XCTAssertEqual(outputMock.cardPaymentDidCloseAfterFailedPaymentCallsCount, 1)
    }
}

// MARK: - Private

extension CardPaymentPresenterTests {
    private func setupSut(
        cardsController: CardsControllerMock? = CardsControllerMock(),
        activeCards: [PaymentCard]? = nil,
        paymentFlow: PaymentFlow = .fullRandom,
        amount: Int64 = 100,
        isCardFieldScanButtonNeeded: Bool = false
    ) {
        viewMock = CardPaymentViewControllerInputMock()
        routerMock = CardPaymentRouterMock()
        outputMock = CardPaymentPresenterModuleOutputMock()
        savedCardViewPresenterAssemblyMock = SavedCardViewPresenterAssemblyMock()
        cardFieldPresenterAssemblyMock = CardFieldPresenterAssemblyMock()
        switchViewPresenterAssemblyMock = SwitchViewPresenterAssemblyMock()
        emailViewPresenterAssemblyMock = EmailViewPresenterAssemblyMock()
        payButtonViewPresenterAssemblyMock = PayButtonViewPresenterAssemblyMock()
        cardListOutputMock = CardListPresenterOutputMock()
        cardsControllerMock = cardsController
        paymentControllerMock = PaymentControllerMock()
        mainDispatchQueueMock = DispatchQueueMock()

        sut = CardPaymentPresenter(
            router: routerMock,
            output: outputMock,
            savedCardViewPresenterAssembly: savedCardViewPresenterAssemblyMock,
            cardFieldPresenterAssembly: cardFieldPresenterAssemblyMock,
            switchViewPresenterAssembly: switchViewPresenterAssemblyMock,
            emailViewPresenterAssembly: emailViewPresenterAssemblyMock,
            payButtonViewPresenterAssembly: payButtonViewPresenterAssemblyMock,
            cardListOutput: cardListOutputMock,
            cardsController: cardsControllerMock,
            paymentController: paymentControllerMock,
            mainDispatchQueue: mainDispatchQueueMock,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: amount,
            isCardFieldScanButtonNeeded: isCardFieldScanButtonNeeded
        )

        sut.view = viewMock
    }

    private func createActiveCardsEmptyArray() -> [PaymentCard] {
        []
    }

    private func createActiveCardsArray() -> [PaymentCard] {
        [
            PaymentCard(
                pan: "220138******0104",
                cardId: "458542919",
                status: .active,
                parentPaymentId: nil,
                expDate: "1129"
            ),
        ]
    }
}

// MARK: - Helpers

extension EmailViewPresenter {
    static func fake() -> EmailViewPresenter {
        EmailViewPresenter(customerEmail: "", output: EmailViewPresenterOutputMock())
    }
}

extension SavedCardViewPresenter {
    static func fake() -> SavedCardViewPresenter {
        SavedCardViewPresenter(
            validator: CardRequisitesValidatorMock(),
            paymentSystemResolver: PaymentSystemResolverMock(),
            bankResolver: BankResolverMock(),
            output: SavedCardViewPresenterOutputMock()
        )
    }
}

private final class FakePayButtonViewPresenterInput: IPayButtonViewPresenterInput {
    var presentationState: PayButtonViewPresentationState = .pay

    var isLoading: Bool = false
    var isEnabled: Bool = false

    func startLoading() {}
    func stopLoading() {}
    func set(enabled: Bool) {}
}
