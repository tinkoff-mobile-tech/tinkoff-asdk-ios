//
//  RecurrentPaymentPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 03.03.2023.
//

import Foundation
import TinkoffASDKCore

final class RecurrentPaymentPresenter: IRecurrentPaymentViewOutput {

    // MARK: Dependencies

    weak var view: IRecurrentPaymentViewInput?

    private let paymentController: IPaymentController
    private let cardsController: ICardsController?
    private var paymentFlow: PaymentFlow
    private let rebillId: String
    private let amount: Int64
    private weak var failureDelegate: IRecurrentPaymentFailiureDelegate?
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: Child Presenters

    private lazy var savedCardPresenter = SavedCardViewPresenter(output: self)
    private lazy var payButtonPresenter = createPayButtonViewPresenter()

    // MARK: State

    private var cellTypes: [RecurrentPaymentCellType] = []
    private var moduleResult: PaymentResult = .cancelled()
    private var additionalData: [String: String] = [:]

    // MARK: Initialization

    init(
        paymentController: IPaymentController,
        cardsController: ICardsController?,
        paymentFlow: PaymentFlow,
        rebillId: String,
        amount: Int64,
        failureDelegate: IRecurrentPaymentFailiureDelegate?,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.paymentController = paymentController
        self.cardsController = cardsController
        self.paymentFlow = paymentFlow
        self.rebillId = rebillId
        self.amount = amount
        self.failureDelegate = failureDelegate
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - IRecurrentPaymentViewOutput

extension RecurrentPaymentPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing)
        paymentController.performPayment(paymentFlow: paymentFlow, paymentSource: .parentPayment(rebuidId: rebillId))
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
        view?.hideKeyboard()
        startPaymentWithSavedCard()
    }
}

// MARK: - ChargePaymentControllerDelegate

extension RecurrentPaymentPresenter: ChargePaymentControllerDelegate {
    func paymentController(
        _ controller: IPaymentController,
        didFinishPayment paymentProcess: IPaymentProcess,
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
        paymentWasCancelled paymentProcess: IPaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {
        moduleResult = .cancelled()
        view?.closeView()
    }

    func paymentController(
        _ controller: IPaymentController,
        shouldRepeatWithRebillId rebillId: String,
        failedPaymentProcess: IPaymentProcess,
        additionalData: [String: String],
        error: Error
    ) {
        moduleResult = .failed(error)
        self.additionalData = additionalData
        paymentFlow = paymentFlow.mergePaymentDataIfNeeded(additionalData)
        getSavedCard(with: rebillId, error: error)
    }
}

// MARK: - Private

extension RecurrentPaymentPresenter {
    private func createPayButtonViewPresenter() -> PayButtonViewPresenter {
        let presenter = PayButtonViewPresenter(presentationState: .payWithAmount(amount: Int(amount)), output: self)
        presenter.set(enabled: false)
        return presenter
    }

    private func getSavedCard(with rebillId: String, error: Error) {
        guard let cardsController = cardsController else {
            let customerKeyError = ASDKError(code: .missingCustomerKey, underlyingError: error)
            moduleResult = .failed(customerKeyError)
            view?.showCommonSheet(state: .failed)
            return
        }

        cardsController.getActiveCards { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(activeCards):
                if let savedCard = activeCards.first(where: { $0.parentPaymentId == Int64(rebillId) }) {
                    self.savedCardPresenter.presentationState = .selected(card: savedCard, showChangeDescription: false)
                    self.cellTypes = [.savedCard(self.savedCardPresenter), .payButton(self.payButtonPresenter)]
                    self.view?.reloadData()
                    self.view?.hideCommonSheet()
                } else {
                    self.view?.showCommonSheet(state: .failed)
                }
            case let .failure(error):
                self.moduleResult = .failed(error)
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
        case let .finish(paymentOptions):
            failureDelegate?.recurrentPaymentNeedRepeatInit(additionalData: additionalData) { [weak self] result in
                guard let self = self else { return }

                DispatchQueue.performOnMain {
                    switch result {
                    case let .success(paymentId):
                        self.paymentController.performFinishPayment(
                            paymentOptions: paymentOptions.updated(with: paymentId),
                            paymentSource: .savedCard(cardId: cardId, cvv: cvc)
                        )
                    case let .failure(error):
                        self.moduleResult = .failed(error)
                        self.view?.showCommonSheet(state: .failed)
                    }
                }
            }
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
        CommonSheetState(
            status: .succeeded,
            title: Loc.CommonSheet.Paid.title,
            primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
        )
    }

    static var failed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.FailedPayment.title,
            primaryButtonTitle: Loc.CommonSheet.FailedPayment.primaryButton
        )
    }
}
