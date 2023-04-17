//
//  CardPaymentPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import Foundation
import TinkoffASDKCore

final class CardPaymentPresenter: ICardPaymentViewControllerOutput {

    // MARK: Dependencies

    weak var view: ICardPaymentViewControllerInput?
    private let router: ICardPaymentRouter
    private weak var output: ICardPaymentPresenterModuleOutput?
    private weak var cardListOutput: ICardListPresenterOutput?

    private let cardsController: ICardsController?
    private let paymentController: IPaymentController

    // MARK: Properties

    private var cellTypes = [CardPaymentCellType]()
    private var savedCardPresenter: SavedCardViewPresenter?
    private lazy var cardFieldPresenter = createCardFieldViewPresenter()
    private lazy var receiptSwitchViewPresenter = createReceiptSwitchViewPresenter()
    private lazy var emailPresenter = createEmailViewPresenter()
    private lazy var payButtonPresenter = createPayButtonViewPresenter()

    private var isCardFieldValid = false

    private var initialActiveCards: [PaymentCard]? {
        didSet {
            guard initialActiveCards != oldValue, let cards = initialActiveCards else { return }
            cardListOutput?.cardList(didUpdate: cards)
        }
    }

    private var activeCards: [PaymentCard] { initialActiveCards ?? [] }
    private let paymentFlow: PaymentFlow
    private let amount: Int64
    private let customerEmail: String

    private let isCardFieldScanButtonNeeded: Bool

    // MARK: Initialization

    init(
        router: ICardPaymentRouter,
        output: ICardPaymentPresenterModuleOutput?,
        cardListOutput: ICardListPresenterOutput?,
        cardsController: ICardsController?,
        paymentController: IPaymentController,
        activeCards: [PaymentCard]?,
        paymentFlow: PaymentFlow,
        amount: Int64,
        isCardFieldScanButtonNeeded: Bool
    ) {
        self.router = router
        self.output = output
        self.cardListOutput = cardListOutput
        self.cardsController = cardsController
        self.paymentController = paymentController
        initialActiveCards = activeCards
        self.paymentFlow = paymentFlow
        self.amount = amount
        customerEmail = paymentFlow.customerOptions?.email ?? ""
        self.isCardFieldScanButtonNeeded = isCardFieldScanButtonNeeded
    }
}

// MARK: - ICardPaymentViewControllerOutput

extension CardPaymentPresenter {
    func viewDidLoad() {
        if initialActiveCards != nil {
            setupInitialStateScreen()
        } else {
            view?.showActivityIndicator(with: .xlYellow)
            loadCards()
        }
    }

    func viewDidAppear() {
        cardFieldPresenter.activate(textFieldType: .cardNumber)
    }

    func closeButtonPressed() {
        router.closeScreen()
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(for row: Int) -> CardPaymentCellType {
        cellTypes[row]
    }
}

// MARK: - ICardFieldOutput

extension CardPaymentPresenter: ICardFieldOutput {
    func scanButtonPressed() {
        router.showCardScanner { [weak self] cardNumber, expiration, cvc in
            self?.cardFieldPresenter.set(textFieldType: .cardNumber, text: cardNumber)
            self?.cardFieldPresenter.set(textFieldType: .expiration, text: expiration)
            self?.cardFieldPresenter.set(textFieldType: .cvc, text: cvc)
        }
    }

    func cardFieldValidationResultDidChange(result: CardFieldValidationResult) {
        isCardFieldValid = result.isValid
        activatePayButtonIfNeeded()
    }
}

// MARK: - IEmailViewPresenterOutput

extension CardPaymentPresenter: IEmailViewPresenterOutput {
    func emailTextFieldDidBeginEditing(_ presenter: EmailViewPresenter) {
        cardFieldPresenter.validateWholeForm()
    }

    func emailTextField(_ presenter: EmailViewPresenter, didChangeEmail email: String, isValid: Bool) {
        activatePayButtonIfNeeded()
    }

    func emailTextFieldDidPressReturn(_ presenter: EmailViewPresenter) {
        cardFieldPresenter.validateWholeForm()
    }
}

// MARK: - ISavedCardViewPresenterOutput

extension CardPaymentPresenter: ISavedCardViewPresenterOutput {
    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didRequestReplacementFor paymentCard: PaymentCard) {
        router.openCardPaymentList(
            paymentFlow: paymentFlow,
            amount: amount,
            cards: activeCards,
            selectedCard: paymentCard,
            cardListOutput: self,
            cardPaymentOutput: output
        )
    }

    func savedCardPresenter(_ presenter: SavedCardViewPresenter, didUpdateCVC cvc: String, isValid: Bool) {
        activatePayButtonIfNeeded()
    }
}

// MARK: - IPayButtonViewPresenterOutput

extension CardPaymentPresenter: IPayButtonViewPresenterOutput {
    func payButtonViewTapped(_ presenter: IPayButtonViewPresenterInput) {
        view?.hideKeyboard()
        view?.startIgnoringInteractionEvents()
        payButtonPresenter.startLoading()

        startPaymentProcess()
    }
}

// MARK: - ICardListPresenterOutput

extension CardPaymentPresenter: ICardListPresenterOutput {
    func cardList(didUpdate cards: [PaymentCard]) {
        initialActiveCards = cards
        savedCardPresenter?.updatePresentationState(for: cards)
        setupInitialStateScreen()
        activatePayButtonIfNeeded()
    }

    func cardList(willCloseAfterSelecting card: PaymentCard) {
        savedCardPresenter?.presentationState = .selected(card: card)
        activatePayButtonIfNeeded()
    }
}

// MARK: - PaymentControllerDelegate

extension CardPaymentPresenter: PaymentControllerDelegate {
    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment: PaymentProcess,
        with state: TinkoffASDKCore.GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        view?.stopIgnoringInteractionEvents()
        let paymentData = FullPaymentData(paymentProcess: didFinishPayment, payload: state, cardId: cardId, rebillId: rebillId)
        output?.cardPaymentWillCloseAfterFinishedPayment(with: paymentData)
        router.closeScreen { [weak self] in
            self?.output?.cardPaymentDidCloseAfterFinishedPayment(with: paymentData)
        }
    }

    func paymentController(
        _ controller: IPaymentController,
        paymentWasCancelled: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        view?.stopIgnoringInteractionEvents()
        output?.cardPaymentWillCloseAfterCancelledPayment(with: paymentWasCancelled, cardId: cardId, rebillId: rebillId)
        router.closeScreen { [weak self] in
            self?.output?.cardPaymentDidCloseAfterCancelledPayment(with: paymentWasCancelled, cardId: cardId, rebillId: rebillId)
        }
    }

    func paymentController(
        _ controller: IPaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        view?.stopIgnoringInteractionEvents()
        output?.cardPaymentWillCloseAfterFailedPayment(with: error, cardId: cardId, rebillId: rebillId)
        router.closeScreen { [weak self] in
            self?.output?.cardPaymentDidCloseAfterFailedPayment(with: error, cardId: cardId, rebillId: rebillId)
        }
    }
}

// MARK: - Private

extension CardPaymentPresenter {
    private func loadCards() {
        guard let cardsController = cardsController else {
            setupInitialStateScreen()
            return
        }

        cardsController.getActiveCards(completion: { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case let .success(cards):
                    self.handleSuccessLoadCards(cards)
                case .failure:
                    self.handleFailureLoadCards()
                }
            }
        })
    }

    private func handleSuccessLoadCards(_ cards: [PaymentCard]) {
        view?.hideActivityIndicator()
        initialActiveCards = cards
        setupInitialStateScreen()
    }

    private func handleFailureLoadCards() {
        view?.hideActivityIndicator()
        setupInitialStateScreen()
    }

    private func setupInitialStateScreen() {
        createSavedCardViewPresenterIfNeeded()

        setupCellTypes()
        view?.reloadTableView()
    }

    private func createSavedCardViewPresenterIfNeeded() {
        guard let activeCard = activeCards.first else { return }

        savedCardPresenter = SavedCardViewPresenter(output: self)
        savedCardPresenter?.presentationState = .selected(card: activeCard)
    }

    private func createCardFieldViewPresenter() -> CardFieldPresenter {
        CardFieldPresenter(output: self, isScanButtonNeeded: isCardFieldScanButtonNeeded)
    }

    private func createReceiptSwitchViewPresenter() -> SwitchViewPresenter {
        SwitchViewPresenter(title: Loc.Acquiring.EmailField.switchButton, isOn: !customerEmail.isEmpty, actionBlock: { [weak self] isOn in
            guard let self = self else { return }

            if isOn {
                let getReceiptIndex = self.cellTypes.firstIndex(of: .getReceipt(self.receiptSwitchViewPresenter)) ?? 0
                let emailIndex = getReceiptIndex + 1
                self.cellTypes.insert(.emailField(self.emailPresenter), at: emailIndex)
                self.view?.insert(row: emailIndex)
            } else if let emailIndex = self.cellTypes.firstIndex(of: .emailField(self.emailPresenter)) {
                self.cellTypes.remove(at: emailIndex)
                self.view?.delete(row: emailIndex)
            }

            self.activatePayButtonIfNeeded()
            self.view?.hideKeyboard()
            self.cardFieldPresenter.validateWholeForm()
        })
    }

    private func createEmailViewPresenter() -> EmailViewPresenter {
        EmailViewPresenter(customerEmail: customerEmail, output: self)
    }

    private func createPayButtonViewPresenter() -> PayButtonViewPresenter {
        let presenter = PayButtonViewPresenter(presentationState: .payWithAmount(amount: Int(amount)), output: self)
        presenter.set(enabled: false)
        return presenter
    }

    private func setupCellTypes() {
        cellTypes = []
        activeCards.isEmpty ? cellTypes.append(.cardField(cardFieldPresenter)) : cellTypes.append(.savedCard(savedCardPresenter))

        if customerEmail.isEmpty {
            cellTypes.append(.getReceipt(receiptSwitchViewPresenter))
        } else {
            cellTypes.append(.getReceipt(receiptSwitchViewPresenter))
            cellTypes.append(.emailField(emailPresenter))
        }

        cellTypes.append(.payButton(payButtonPresenter))
    }

    private func activatePayButtonIfNeeded() {
        let isSavedCardValid = savedCardPresenter?.isValid ?? false
        let isSavedCardExist = !activeCards.isEmpty
        let isCardValid = isSavedCardExist ? isSavedCardValid : isCardFieldValid

        let isEmailFieldOn = receiptSwitchViewPresenter.isOn
        let isEmailFieldValid = emailPresenter.isEmailValid
        let isEmailValid = isEmailFieldOn ? isEmailFieldValid : true

        let isPayButtonEnabled = isCardValid && isEmailValid
        payButtonPresenter.set(enabled: isPayButtonEnabled)
    }

    private func startPaymentProcess() {
        let cardSourceData = PaymentSourceData.cardNumber(
            number: cardFieldPresenter.cardNumber,
            expDate: cardFieldPresenter.expiration,
            cvv: cardFieldPresenter.cvc
        )
        let savedCardSourceData = PaymentSourceData.savedCard(
            cardId: savedCardPresenter?.cardId ?? "",
            cvv: savedCardPresenter?.cvc
        )

        let sourceData: PaymentSourceData = activeCards.isEmpty ? cardSourceData : savedCardSourceData
        let email = receiptSwitchViewPresenter.isOn ? emailPresenter.currentEmail : nil

        let paymentFlow = (activeCards.isEmpty ? paymentFlow.withNewCardAnalytics() : paymentFlow.withSavedCardAnalytics())
            .replacing(customerEmail: email)

        paymentController.performPayment(
            paymentFlow: paymentFlow,
            paymentSource: sourceData
        )
    }
}
