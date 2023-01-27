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

    // MARK: Properties

    private var cellTypes = [CardPaymentCellType]()
    private var savedCardPresenter: SavedCardPresenter?
    private lazy var receiptSwitchViewPresenter = createReceiptSwitchViewPresenter()

    private var isCardFieldValid = false

    private let activeCards: [PaymentCard]
    private var customerEmail: String

    // MARK: Initialization

    init(
        router: ICardPaymentRouter,
        activeCards: [PaymentCard],
        customerEmail: String
    ) {
        self.router = router
        self.activeCards = activeCards
        self.customerEmail = customerEmail
    }
}

// MARK: - ICardPaymentViewControllerOutput

extension CardPaymentPresenter {
    func viewDidLoad() {
        createSavedCardViewPresenterIfNeeded()

        view?.setPayButton(title: "Оплатить 1 070 724 ₽")
        view?.setPayButton(isEnabled: false)
        view?.setEmailTextField(text: customerEmail)

        setupCellTypes()
        view?.reloadTableView()

//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.view?.reloadTableView()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                self.view?.reloadTableView()
//            }
//        }
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
        guard text != customerEmail else { return }

        customerEmail = text
        activatePayButtonIfNeeded()
    }

    func emailTextFieldDidEndEditing() {
        let isValid = isValidEmail(customerEmail)
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
        SwitchViewPresenter(title: "Получить квитанцию", isOn: !customerEmail.isEmpty, actionBlock: { [weak self] isOn in
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
        if activeCards.isEmpty, customerEmail.isEmpty {
            cellTypes = [.cardField, .getReceipt, .payButton]
        } else if activeCards.isEmpty {
            cellTypes = [.cardField, .getReceipt, .emailField, .payButton]
        } else if !activeCards.isEmpty, customerEmail.isEmpty {
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
        let isEmailFieldValid = isValidEmail(customerEmail)
        let isEmailValid = isEmailFieldOn ? isEmailFieldValid : true

        let isPayButtonEnabled = isCardValid && isEmailValid
        view?.setPayButton(isEnabled: isPayButtonEnabled)
    }
}
