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
    private let stub: MainFormStub

    // MARK: Child Presenters

    private lazy var savedCardPresenter = SavedCardPresenter(output: self)

    // MARK: State

    private var presenters: [MainFormViewPresenterType] { [.savedCard(savedCardPresenter)] }

    // MARK: Init

    init(router: IMainFormRouter, stub: MainFormStub) {
        self.router = router
        self.stub = stub
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        let paymentCard = PaymentCard(
            pan: "2201382000000039",
            cardId: "123456",
            status: .active,
            parentPaymentId: nil,
            expDate: "1030"
        )

        savedCardPresenter.presentationState = .selected(
            card: paymentCard,
            hasAnotherCards: true
        )

        let orderDetails = MainFormOrderDetailsViewModel(
            amountDescription: "К оплате",
            amount: "10 500 ₽",
            orderDescription: "Заказ №123456"
        )

        let paymentControls = MainFormPaymentControlsViewModel(
            buttonType: .primary(title: "Оплатить картой")
        )

        let header = MainFormHeaderViewModel(
            orderDetails: orderDetails,
            paymentControls: paymentControls
        )

        view?.updateHeader(with: header)
    }

    func viewWasClosed() {}

    func viewDidTapPayButton() {
        router.openCardPaymentForm()
    }

    func numberOfRows() -> Int {
        presenters.count
    }

    func viewPresenter(at index: Int) -> MainFormViewPresenterType {
        presenters[index]
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
        view?.set(payButtonEnabled: isValid)
    }
}
