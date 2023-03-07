//
//  RecurrentPaymentPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

import TinkoffASDKCore

final class RecurrentPaymentPresenter: IRecurrentPaymentViewOutput {

    // MARK: Dependencies

    weak var view: IRecurrentPaymentViewInput?

    private let paymentController: IPaymentController
    private let cardsController: ICardsController?
    private var paymentFlow: PaymentFlow
    private let rebuilId: String
    private let amount: Int64
    private weak var failureDelegate: IRecurrentPaymentFailiureDelegate?
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: Child Presenters

    private lazy var savedCardPresenter = SavedCardViewPresenter(output: self)
    private lazy var payButtonPresenter = createPayButtonViewPresenter()

    // MARK: State

    private var cellTypes: [RecurrentPaymentCellType] = []
    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Initialization

    init(
        paymentController: IPaymentController,
        cardsController: ICardsController?,
        paymentFlow: PaymentFlow,
        rebuilId: String,
        amount: Int64,
        failureDelegate: IRecurrentPaymentFailiureDelegate?,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.paymentController = paymentController
        self.cardsController = cardsController
        self.paymentFlow = paymentFlow
        self.rebuilId = rebuilId
        self.amount = amount
        self.failureDelegate = failureDelegate
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - IRecurrentPaymentViewOutput

extension RecurrentPaymentPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing)
        paymentController.performPayment(paymentFlow: paymentFlow, paymentSource: .parentPayment(rebuidId: rebuilId))
    }

    func viewWasClosed() {
        moduleCompletion?(moduleResult)
        moduleCompletion = nil
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(at indexPath: IndexPath) -> RecurrentPaymentCellType {
        cellTypes[indexPath.row]
    }

    func commonSheetViewDidTapPrimaryButton() {
        view?.closeView()
    }
}

// MARK: - ISavedCardViewPresenterOutput

extension RecurrentPaymentPresenter: ISavedCardViewPresenterOutput {
    func savedCardPresenter(
        _ presenter: SavedCardViewPresenter,
        didUpdateCVC cvc: String,
        isValid: Bool
    ) {
        activatePayButtonIfNeeded()
    }
}

// MARK: - IPayButtonViewPresenterOutput

extension RecurrentPaymentPresenter: IPayButtonViewPresenterOutput {
    func payButtonViewTapped(_ presenter: IPayButtonViewPresenterInput) {
        startPaymentWithSavedCard()
    }
}

// MARK: - ChargePaymentControllerDelegate

extension RecurrentPaymentPresenter: ChargePaymentControllerDelegate {
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

    func paymentController(
        _ controller: IPaymentController,
        shouldRepeatWithRebillId rebillId: String,
        failedPaymentProcess: PaymentProcess,
        error: Error
    ) {
        moduleResult = .failed(error)

        switch failedPaymentProcess.paymentFlow {
        case let .full(paymentOptions):
            paymentFlow = paymentFlow.replacingPaymentDataIfNeeded(paymentData: paymentOptions.paymentData)
        case .finish:
            break
        }

        getSavedCard(with: rebillId)
    }
}

// MARK: - Private

extension RecurrentPaymentPresenter {
    private func createPayButtonViewPresenter() -> PayButtonViewPresenter {
        let presenter = PayButtonViewPresenter(presentationState: .payWithAmount(amount: Int(amount)), output: self)
        presenter.set(enabled: false)
        return presenter
    }

    private func getSavedCard(with rebillId: String) {
        guard let cardsController = cardsController else {
            // как то дополнительно уведомить, что надо было передавать customerKey, для корректной работы
            view?.showCommonSheet(state: .failed)
            return
        }

        cardsController.getActiveCards { [weak self] result in
            guard let self = self else { return }

            switch result {
            case var .success(activeCards):
                var activeCard = activeCards.first
                activeCard?.parentPaymentId = Int64(rebillId) // временно для тестов
                activeCards[0] = activeCard!
                if let savedCard = activeCards.first(where: { $0.parentPaymentId == Int64(rebillId) }) {
                    self.savedCardPresenter.presentationState = .selected(card: savedCard, hasAnotherCards: false)
                    self.cellTypes = [.savedCard(self.savedCardPresenter), .payButton(self.payButtonPresenter)]
                    self.view?.reloadData()
                    self.view?.hideCommonSheet()
                } else {
                    self.view?.showCommonSheet(state: .failed)
                }
            case .failure:
                self.view?.showCommonSheet(state: .failed)
            }
        }
    }

    private func activatePayButtonIfNeeded() {
        payButtonPresenter.set(enabled: savedCardPresenter.isValid)
    }

    private func startPaymentWithSavedCard() {
        guard let cardId = savedCardPresenter.cardId, let cvc = savedCardPresenter.cvc else {
            return
        }

        switch paymentFlow {
        case let .full(paymentOptions):
            paymentController.performInitPayment(
                paymentOptions: paymentOptions,
                paymentSource: .savedCard(cardId: cardId, cvv: cvc)
            )
        case let .finish(_, customerOptions):
            failureDelegate?.recurrentPaymentNeedRepeatInit(completion: { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.performOnMain {
                    switch result {
                    case let .success(paymentId):
                        self.paymentController.performFinishPayment(
                            paymentId: paymentId,
                            paymentSource: .savedCard(cardId: cardId, cvv: cvc),
                            customerOptions: customerOptions
                        )
                    case .failure:
                        self.view?.showCommonSheet(state: .failed)
                    }
                }
            })
        }

        payButtonPresenter.startLoading()
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
