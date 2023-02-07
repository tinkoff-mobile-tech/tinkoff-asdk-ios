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

    private lazy var savedCardPresenter = SavedCardPresenter(output: self)
    private lazy var getReceiptSwitchPresenter = SwitchViewPresenter(title: "Получить квитанцию")

    // MARK: State

    private lazy var cellTypes: [MainFormCellType] = [
        .orderDetails,
        .savedCard(savedCardPresenter),
        .getReceiptSwitch(getReceiptSwitchPresenter),
        .payButton,
        .otherPaymentMethodsHeader,
        .otherPaymentMethod(.tinkoffPay),
        .otherPaymentMethod(.card),
        .otherPaymentMethod(.sbp),
    ]

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
        let orderDetails = MainFormOrderDetailsViewModel(
            amountDescription: "К оплате",
            amount: "10 500 ₽",
            orderDescription: "Заказ №123456"
        )

        view?.updateOrderDetails(with: orderDetails)
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
