//
//  MainFormPresenter.swift
//  TinkoffASDKUI
//
//  Created by r.akhmadeev on 19.01.2023.
//

import Foundation
import TinkoffASDKCore

final class MainFormPresenter {
    // MARK: Dependencies

    weak var view: IMainFormViewController?
    private let router: IMainFormRouter
    private let cardsController: ICardsController?
    private let paymentController: IPaymentController
    private let paymentFlow: PaymentFlow
    private let configuration: MainFormUIConfiguration
    private let stub: MainFormStub
    private var moduleCompletion: ((PaymentResult) -> Void)?

    // MARK: Child Presenters

    private lazy var orderDetailsPresenter = MainFormOrderDetailsViewPresenter(
        amount: configuration.amount,
        orderDescription: configuration.orderDescription
    )

    private lazy var savedCardPresenter = SavedCardPresenter(output: self)

    private lazy var getReceiptSwitchPresenter = SwitchViewPresenter(
        title: "Получить квитанцию",
        isOn: paymentFlow.customerOptions?.email?.isEmpty == false,
        actionBlock: { [weak self] in self?.getReceiptSwitch(didChange: $0) }
    )

    private lazy var emailPresenter = EmailViewPresenter(
        customerEmail: paymentFlow.customerOptions?.email ?? "",
        output: self
    )
    private lazy var payButtonPresenter = PayButtonViewPresenter(output: self)
    private lazy var otherPaymentMethodsHeaderPresenter = TextHeaderViewPresenter(title: "Оплатить другим способом")

    // MARK: State

    private lazy var cellTypes: [MainFormCellType] = []
    private var cards: [PaymentCard] = []
    private var availablePaymentMethods: [MainFormPaymentMethod] = MainFormPaymentMethod.allCases
    private lazy var primaryPaymentMethod = stub.primaryPayMethod.domainModel
    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Init

    init(
        router: IMainFormRouter,
        cardsController: ICardsController?,
        paymentController: IPaymentController,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub,
        moduleCompletion: @escaping (PaymentResult) -> Void
    ) {
        self.router = router
        self.cardsController = cardsController
        self.paymentController = paymentController
        self.paymentFlow = paymentFlow
        self.configuration = configuration
        self.stub = stub
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing)

        loadCardsIfNeeded { [weak self] in
            guard let self = self else { return }

            // Временно
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.view?.hideCommonSheet()
                self.reloadContent()
            }
        }
    }

    func viewWasClosed() {
        moduleCompletion?(moduleResult)
        moduleCompletion = nil
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(at indexPath: IndexPath) -> MainFormCellType {
        cellTypes[indexPath.row]
    }

    func didSelectRow(at indexPath: IndexPath) {
        switch cellType(at: indexPath) {
        case let .otherPaymentMethod(paymentMethod):
            routeTo(paymentMethod: paymentMethod)
        default:
            break
        }
    }

    func commonSheetViewDidTapPrimaryButton() {
        view?.closeView()
    }
}

// MARK: - ICardListPresenterOutput

extension MainFormPresenter: ICardListPresenterOutput {
    func cardList(didSelect card: PaymentCard) {
        savedCardPresenter.presentationState = .selected(card: card, hasAnotherCards: cards.count > 1)
        router.closeCardSelection()
    }

    func cardList(didRemoveCard card: PaymentCard) {
        cards.removeAll { $0.cardId == card.cardId }
        reloadContent()
    }

    func cardListDidSelectNewCard() {
        router.pushNewCardPaymentToCardSelection(paymentFlow: paymentFlow, output: self)
    }
}

// MARK: - ISavedCardPresenterOutput

extension MainFormPresenter: ISavedCardPresenterOutput {
    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didRequestReplacementFor paymentCard: PaymentCard
    ) {
        router.openCardSelection(
            paymentFlow: paymentFlow,
            cards: cards,
            selectedCard: paymentCard, output: self
        )
    }

    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didUpdateCVC cvc: String,
        isValid: Bool
    ) {
        activatePayButtonIfNeeded()
    }
}

// MARK: - SwitchViewOutput

extension MainFormPresenter {
    func getReceiptSwitch(didChange isOn: Bool) {
        guard let switchIndex = cellTypes.firstIndex(where: \.isGetReceiptSwitch) else {
            return assertionFailure()
        }

        let emailIndex = switchIndex + 1
        let emailIndexPath = IndexPath(row: emailIndex, section: .zero)

        if isOn {
            assert(!cellTypes.contains(where: \.isEmail))
            cellTypes.insert(.email(emailPresenter), at: emailIndex)
            view?.insertRow(at: emailIndexPath)
        } else {
            assert(cellTypes.firstIndex(where: \.isEmail) == emailIndex)
            cellTypes.remove(at: emailIndex)
            view?.deleteRow(at: emailIndexPath)
        }

        activatePayButtonIfNeeded()
    }
}

// MARK: - IPayButtonViewPresenterOutput

extension MainFormPresenter: IPayButtonViewPresenterOutput {
    func payButtonViewTapped(_ presenter: IPayButtonViewPresenterInput) {
        switch primaryPaymentMethod {
        case .card where !cards.isEmpty:
            startPaymentWithSavedCard()
            presenter.startLoading()
        case .card, .tinkoffPay, .sbp:
            routeTo(paymentMethod: primaryPaymentMethod)
        }
    }
}

// MARK: - IEmailViewPresenterOutput

extension MainFormPresenter: IEmailViewPresenterOutput {
    func emailTextField(
        _ presenter: EmailViewPresenter,
        didChangeEmail email: String,
        isValid: Bool
    ) {
        activatePayButtonIfNeeded()
    }
}

// MARK: - PaymentControllerDelegate

extension MainFormPresenter: PaymentControllerDelegate {
    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment paymentProcess: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {
        moduleResult = .succeeded(state.toPaymentInfo())
        view?.showCommonSheet(state: .paid)
    }

    func paymentController(
        _ controller: IPaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        moduleResult = .failed(error)
        view?.showCommonSheet(state: .failed)
    }

    func paymentController(
        _ controller: IPaymentController,
        paymentWasCancelled paymentProcess: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        moduleResult = .cancelled()
        view?.closeView()
    }
}

// MARK: - ICardPaymentPresenterModuleOutput

extension MainFormPresenter: ICardPaymentPresenterModuleOutput {
    func cardPaymentWillCloseAfterFinishedPayment(with paymentData: FullPaymentData) {
        moduleResult = .succeeded(paymentData.payload.toPaymentInfo())
        view?.showCommonSheet(state: .paid)
    }

    func cardPaymentWillCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?) {
        moduleResult = .failed(error)
        view?.showCommonSheet(state: .failed)
    }

    func cardPaymentDidCloseAfterCancelledPayment(with paymentProcess: PaymentProcess, cardId: String?, rebillId: String?) {
        moduleResult = .cancelled()
        view?.closeView()
    }
}

// MARK: - ISBPPaymentSheetPresenterOutput

extension MainFormPresenter: ISBPPaymentSheetPresenterOutput {
    func sbpPaymentSheet(completedWith result: PaymentResult) {
        switch result {
        case .succeeded, .failed:
            moduleResult = result
            view?.closeView()
        case let .cancelled(paymentInfo) where paymentInfo != nil:
            moduleResult = result
            view?.closeView()
        case .cancelled:
            break
        }
    }
}

// MARK: - MainFormPresenter + Helpers

extension MainFormPresenter {
    private func loadCardsIfNeeded(completion: @escaping VoidBlock) {
        guard let cardsController = cardsController else {
            return completion()
        }

        cardsController.getActiveCards { [weak self] result in
            guard let self = self else { return }
            defer { completion() }

            guard let cards = try? result.get(),
                  let selectedCard = cards.first else { return }

            self.cards = cards

            self.savedCardPresenter.presentationState = .selected(
                card: selectedCard,
                hasAnotherCards: cards.count > 1
            )
        }
    }

    private func activatePayButtonIfNeeded() {
        guard primaryPaymentMethod == .card else {
            payButtonPresenter.set(enabled: true)
            return
        }

        let isCvcValid = cards.isEmpty ? true : savedCardPresenter.isValid
        let isEmailValid = getReceiptSwitchPresenter.isOn ? emailPresenter.isEmailValid : true

        payButtonPresenter.set(enabled: isCvcValid && isEmailValid)
    }

    private func startPaymentWithSavedCard() {
        guard let cardId = savedCardPresenter.cardId,
              let cvc = savedCardPresenter.cvc else { return }

        let email = getReceiptSwitchPresenter.isOn ? emailPresenter.currentEmail : nil

        paymentController.performPayment(
            paymentFlow: paymentFlow.replacing(customerEmail: email),
            paymentSource: .savedCard(cardId: cardId, cvv: cvc)
        )
    }
}

// MARK: - MainFormPresenter + Routing

extension MainFormPresenter {
    private func routeTo(paymentMethod: MainFormPaymentMethod) {
        switch paymentMethod {
        case .card:
            router.openCardPayment(paymentFlow: paymentFlow, cards: cards, output: self)
        case .tinkoffPay:
            router.openTinkoffPay(paymentFlow: paymentFlow)
        case .sbp:
            router.openSBP(paymentFlow: paymentFlow, paymentSheetOutput: self)
        }
    }
}

// MARK: - MainFormPresenter + Rows Creations

extension MainFormPresenter {
    private func reloadContent() {
        payButtonPresenter.presentationState = .presentationState(from: primaryPaymentMethod)
        activatePayButtonIfNeeded()
        cellTypes = createPrimaryPaymentMethodRows() + createOtherPaymentMethodsRows()
        view?.reloadData()
    }

    private func createPrimaryPaymentMethodRows() -> [MainFormCellType] {
        var rows: [MainFormCellType] = [.orderDetails(orderDetailsPresenter)]

        switch primaryPaymentMethod {
        case .card where !cards.isEmpty:
            rows.append(.savedCard(savedCardPresenter))
            rows.append(.getReceiptSwitch(getReceiptSwitchPresenter))

            if getReceiptSwitchPresenter.isOn {
                rows.append(.email(emailPresenter))
            }
        case .card, .tinkoffPay, .sbp:
            break
        }

        rows.append(.payButton(payButtonPresenter))

        return rows
    }

    private func createOtherPaymentMethodsRows() -> [MainFormCellType] {
        let otherPaymentMethods = MainFormPaymentMethod
            .allCases
            .filter(availablePaymentMethods.contains)
            .filter { $0 != primaryPaymentMethod }
            .sorted(by: <)
            .map(MainFormCellType.otherPaymentMethod)

        guard !otherPaymentMethods.isEmpty else { return [] }
        let header: MainFormCellType = .otherPaymentMethodsHeader(otherPaymentMethodsHeaderPresenter)

        return CollectionOfOne(header) + otherPaymentMethods
    }
}

// MARK: - PayButtonPresentationState + Helper

private extension PayButtonViewPresentationState {
    static func presentationState(from paymentMethod: MainFormPaymentMethod) -> PayButtonViewPresentationState {
        switch paymentMethod {
        case .tinkoffPay:
            return .tinkoffPay
        case .card:
            return .pay
        case .sbp:
            return .sbp
        }
    }
}

// MARK: - CommonSheetState + MainForm States

private extension CommonSheetState {
    static var processing: CommonSheetState {
        CommonSheetState(status: .processing)
    }

    static var paid: CommonSheetState {
        CommonSheetState(status: .succeeded, title: "Оплачено", primaryButtonTitle: "Понятно")
    }

    static var failed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: "Не получилось оплатить",
            primaryButtonTitle: "Понятно"
        )
    }
}
