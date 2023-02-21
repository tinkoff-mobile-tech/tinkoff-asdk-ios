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

    private let cardsController: ICardsController
    private let paymentController: IPaymentController

    // MARK: Properties

    private var cellTypes = [CardPaymentCellType]()
    private var savedCardPresenter: SavedCardPresenter?
    private lazy var cardFieldPresenter = createCardFieldViewPresenter()
    private lazy var receiptSwitchViewPresenter = createReceiptSwitchViewPresenter()
    private lazy var emailPresenter = createEmailViewPresenter()
    private lazy var payButtonPresenter = createPayButtonViewPresenter()

    private var isCardFieldValid = false

    private var initialActiveCards: [PaymentCard]?
    private var activeCards: [PaymentCard] { initialActiveCards ?? [] }
    private let paymentFlow: PaymentFlow
    private let amount: Int
    private let customerEmail: String

    // MARK: Initialization

    init(
        router: ICardPaymentRouter,
        output: ICardPaymentPresenterModuleOutput?,
        cardsController: ICardsController,
        paymentController: IPaymentController,
        activeCards: [PaymentCard]?,
        paymentFlow: PaymentFlow,
        amount: Int
    ) {
        self.router = router
        self.output = output
        self.cardsController = cardsController
        self.paymentController = paymentController
        initialActiveCards = Int.random(in: 0 ... 100) % 2 == 0 ? nil : []
        self.paymentFlow = paymentFlow
        self.amount = amount

        customerEmail = Int.random(in: 0 ... 100) % 2 == 0 ? paymentFlow.customerOptions?.email ?? "" : ""
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

// MARK: - ISavedCardPresenterOutput

extension CardPaymentPresenter: ISavedCardPresenterOutput {
    func savedCardPresenter(_ presenter: SavedCardPresenter, didRequestReplacementFor paymentCard: PaymentCard) {
        // логика открытия экрана со спиком карт
    }

    func savedCardPresenter(_ presenter: SavedCardPresenter, didUpdateCVC cvc: String, isValid: Bool) {
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

        let hasAnotherCards = activeCards.count > 1
        savedCardPresenter = SavedCardPresenter(output: self)
        savedCardPresenter?.presentationState = .selected(card: activeCard, hasAnotherCards: hasAnotherCards)
    }

    private func createCardFieldViewPresenter() -> CardFieldPresenter {
        CardFieldPresenter(output: self)
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
        let presenter = PayButtonViewPresenter(presentationState: .payWithAmount(amount: amount), output: self)
        presenter.set(enabled: false)
        return presenter
    }

    private func setupCellTypes() {
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

        paymentController.performPayment(
            paymentFlow: paymentFlow.replacing(customerEmail: email),
            paymentSource: sourceData
        )
    }
}
