//
//  CardPaymentPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore

enum CardPaymentCellType {
    case savedCard
    case cardField
    case getReceipt
    case emailField
    case payButton
}

final class CardPaymentPresenter: ICardPaymentViewControllerOutput {

    // MARK: Dependencies

    weak var view: ICardPaymentViewControllerInput?
    private let router: ICardPaymentRouter
    private let moneyFormatter: IMoneyFormatter

    // MARK: Properties

    private var cellTypes = [CardPaymentCellType]()
    private var savedCardPresenter: SavedCardPresenter?
    private lazy var receiptSwitchViewPresenter = createReceiptSwitchViewPresenter()

    private var isCardFieldValid = false

    private let activeCards: [PaymentCard]
    private let paymentFlow: PaymentFlow
    private let amount: Int
    private lazy var currentEmail = getCustomerEmailFromPaymentFlow()

    // MARK: Initialization

    init(
        router: ICardPaymentRouter,
        moneyFormatter: IMoneyFormatter,
        activeCards: [PaymentCard],
        paymentFlow: PaymentFlow,
        amount: Int
    ) {
        self.router = router
        self.moneyFormatter = moneyFormatter
        self.activeCards = activeCards
        self.paymentFlow = paymentFlow
        self.amount = amount
    }
}

// MARK: - ICardPaymentViewControllerOutput

extension CardPaymentPresenter {
    func viewDidLoad() {
        createSavedCardViewPresenterIfNeeded()

        let stringAmount = moneyFormatter.formatAmount(amount)
        view?.setPayButton(title: "Оплатить \(stringAmount)")
        view?.setPayButton(isEnabled: false)
        view?.setEmailTextField(text: currentEmail)

        setupCellTypes()
        view?.reloadTableView()
    }

    func closeButtonPressed() {
        router.closeScreen()
    }

    func payButtonPressed() {
        view?.hideKeyboard()
        view?.startLoadingPayButton()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.view?.stopLoadingPayButton()
        }
    }

    func cardFieldDidChangeState(isValid: Bool) {
        isCardFieldValid = isValid
        activatePayButtonIfNeeded()
    }

    func emailTextFieldDidBeginEditing() {
        view?.setEmailHeader(isError: false)
        view?.forceValidateCardField()
    }

    func emailTextFieldDidChangeText(to text: String) {
        guard text != currentEmail else { return }

        currentEmail = text
        activatePayButtonIfNeeded()
    }

    func emailTextFieldDidEndEditing() {
        let isValid = isValidEmail(currentEmail)
        view?.setEmailHeader(isError: !isValid)
    }

    func emailTextFieldDidPressReturn() {
        view?.hideKeyboard()
        view?.forceValidateCardField()
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(for row: Int) -> CardPaymentCellType {
        cellTypes[row]
    }

    func savedCardViewPresenter() -> SavedCardPresenter? {
        savedCardPresenter
    }

    func switchViewPresenter() -> SwitchViewPresenter {
        receiptSwitchViewPresenter
    }
}

// MARK: - ISavedCardPresenterOutput

extension CardPaymentPresenter: ISavedCardPresenterOutput {
    func savedCardPresenter(_ presenter: SavedCardPresenter, didRequestReplacementFor paymentCard: PaymentCard) {}

    func savedCardPresenter(_ presenter: SavedCardPresenter, didUpdateCVC cvc: String, isValid: Bool) {
        activatePayButtonIfNeeded()
    }
}

// MARK: - Private

extension CardPaymentPresenter {
    private func createSavedCardViewPresenterIfNeeded() {
        guard let activeCard = activeCards.first else { return }

        let hasAnotherCards = activeCards.count > 1
        savedCardPresenter = SavedCardPresenter(output: self)
        savedCardPresenter?.presentationState = .selected(card: activeCard, hasAnotherCards: hasAnotherCards)
    }

    private func createReceiptSwitchViewPresenter() -> SwitchViewPresenter {
        SwitchViewPresenter(title: "Получить квитанцию", isOn: !currentEmail.isEmpty, actionBlock: { [weak self] isOn in
            guard let self = self else { return }

            if isOn {
                let getReceiptIndex = self.cellTypes.firstIndex(of: .getReceipt) ?? 0
                let emailIndex = getReceiptIndex + 1
                self.cellTypes.insert(.emailField, at: emailIndex)
                self.view?.insert(row: emailIndex)
            } else if let emailIndex = self.cellTypes.firstIndex(of: .emailField) {
                self.cellTypes.remove(at: emailIndex)
                self.view?.delete(row: emailIndex)
            }

            self.activatePayButtonIfNeeded()
            self.view?.hideKeyboard()
            self.view?.forceValidateCardField()
        })
    }

    private func setupCellTypes() {
        if activeCards.isEmpty, currentEmail.isEmpty {
            cellTypes = [.cardField, .getReceipt, .payButton]
        } else if activeCards.isEmpty {
            cellTypes = [.cardField, .getReceipt, .emailField, .payButton]
        } else if !activeCards.isEmpty, currentEmail.isEmpty {
            cellTypes = [.savedCard, .getReceipt, .payButton]
        } else if !activeCards.isEmpty {
            cellTypes = [.savedCard, .getReceipt, .emailField, .payButton]
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = ".+\\@.+\\..+"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func activatePayButtonIfNeeded() {
        let isSavedCardValid = savedCardPresenter?.isValid ?? false
        let isSavedCardExist = !activeCards.isEmpty
        let isCardValid = isSavedCardExist ? isSavedCardValid : isCardFieldValid

        let isEmailFieldOn = receiptSwitchViewPresenter.isOn
        let isEmailFieldValid = isValidEmail(currentEmail)
        let isEmailValid = isEmailFieldOn ? isEmailFieldValid : true

        let isPayButtonEnabled = isCardValid && isEmailValid
        view?.setPayButton(isEnabled: isPayButtonEnabled)
    }

    private func getCustomerEmailFromPaymentFlow() -> String {
        switch paymentFlow {
        case let .full(paymentOptions):
            return paymentOptions.customerOptions?.email ?? ""
        case let .finish(_, customerOptions):
            return customerOptions?.email ?? ""
        }
    }
}
