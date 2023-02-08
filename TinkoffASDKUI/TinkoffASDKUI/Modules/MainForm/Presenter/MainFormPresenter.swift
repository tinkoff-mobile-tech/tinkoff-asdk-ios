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
    private let coreSDK: AcquiringSdk
    private let paymentFlow: PaymentFlow
    private let configuration: MainFormUIConfiguration
    private let stub: MainFormStub

    // MARK: Child Presenters

    private lazy var orderDetailsPresenter = MainFormOrderDetailsViewPresenter(
        amount: configuration.amount,
        orderDescription: configuration.orderDescription
    )

    private lazy var savedCardPresenter = SavedCardPresenter(output: self)
    private lazy var getReceiptSwitchPresenter = SwitchViewPresenter(
        title: "Получить квитанцию",
        isOn: true,
        actionBlock: { [weak self] in self?.getReceiptSwitch(didChange: $0) }
    )
    private lazy var emailPresenter = EmailViewPresenter(
        customerEmail: paymentFlow.customerOptions?.email ?? "",
        output: self
    )

    // MARK: State

    private lazy var cellTypes: [MainFormCellType] = []
    private var loadedCards: [PaymentCard] = []

    // MARK: Init

    init(
        router: IMainFormRouter,
        coreSDK: AcquiringSdk,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub
    ) {
        self.router = router
        self.coreSDK = coreSDK
        self.paymentFlow = paymentFlow
        self.configuration = configuration
        self.stub = stub
    }

    // MARK: Helpers

    private func loadCardsIfNeeded() {
        guard let customerKey = paymentFlow.customerOptions?.customerKey else { return }

        coreSDK.getCardList(data: GetCardListData(customerKey: customerKey)) { [weak self] result in
            guard let cards = try? result.get() else { return }
            let activeCards = cards.filter { $0.status == .active }

            guard let selectedCard = activeCards.first else { return }

            DispatchQueue.main.async {
                self?.loadedCards = activeCards
                self?.savedCardPresenter.presentationState = .selected(
                    card: selectedCard,
                    hasAnotherCards: activeCards.count > 1
                )
            }
        }
    }

    private func setupButtonAppearance() {
        switch stub.primaryPayMethod {
        case .card:
            view?.setButtonPrimaryAppearance()
        case .tinkoffPay:
            view?.setButtonTinkoffPayAppearance()
        case .sbp:
            view?.setButtonSBPAppearance()
        }
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        cellTypes = [
            .orderDetails(orderDetailsPresenter),
            .savedCard(savedCardPresenter),
            .getReceiptSwitch(getReceiptSwitchPresenter),
            .email(emailPresenter),
//            .payButton,
            .otherPaymentMethodsHeader,
            .otherPaymentMethod(.tinkoffPay),
            .otherPaymentMethod(.card),
            .otherPaymentMethod(.sbp),
        ]
        setupButtonAppearance()
        loadCardsIfNeeded()
    }

    func viewWasClosed() {}

    func viewDidTapPayButton() {
        switch stub.primaryPayMethod {
        case .card:
            router.openCardPaymentForm(paymentFlow: paymentFlow, cards: loadedCards, output: self)
        case .tinkoffPay:
            router.openTinkoffPay(paymentFlow: paymentFlow)
        case .sbp:
            router.openSBP(paymentFlow: paymentFlow)
        }
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(at indexPath: IndexPath) -> MainFormCellType {
        cellTypes[indexPath.row]
    }

    func didSelectRow(at indexPath: IndexPath) {
        switch cellType(at: indexPath) {
        case .otherPaymentMethod(.card):
            router.openCardPaymentForm(paymentFlow: paymentFlow, cards: loadedCards, output: self)
        case .otherPaymentMethod(.tinkoffPay):
            router.openTinkoffPay(paymentFlow: paymentFlow)
        case .otherPaymentMethod(.sbp):
            router.openSBP(paymentFlow: paymentFlow)
        default:
            break
        }
    }
}

// MARK: - ICardPaymentPresenterModuleOutput

extension MainFormPresenter: ICardPaymentPresenterModuleOutput {
    func cardPaymentPayButtonDidPressed(cardData: CardData, email: String?) {
        // логика с PaymentController
    }
}

// MARK: - ISavedCardPresenterOutput

extension MainFormPresenter: ISavedCardPresenterOutput {
    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didRequestReplacementFor paymentCard: PaymentCard
    ) {}

    func savedCardPresenter(
        _ presenter: SavedCardPresenter,
        didUpdateCVC cvc: String,
        isValid: Bool
    ) {
//        view?.setButtonEnabled(isValid)
    }
}

// MARK: - SwitchViewOutput

extension MainFormPresenter {
    func getReceiptSwitch(didChange isOn: Bool) {
        guard let switchIndex = cellTypes.firstIndex(where: \.isGetReceiptSwitch) else { return }
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
    }
}

// MARK: - IEmailViewPresenterOutput

extension MainFormPresenter: IEmailViewPresenterOutput {
    func emailTextField(
        _ presenter: EmailViewPresenter,
        didChangeEmail email: String,
        isValid: Bool
    ) {}
}
