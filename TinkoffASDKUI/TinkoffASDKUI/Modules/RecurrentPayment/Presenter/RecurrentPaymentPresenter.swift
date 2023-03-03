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
    private let paymentFlow: PaymentFlow
    private let paymentSource: PaymentSourceData
    private var moduleCompletion: PaymentResultCompletion?
    
    // MARK: Child Presenters
    
    private lazy var savedCardPresenter = SavedCardViewPresenter(output: self)
    private lazy var payButtonPresenter = PayButtonViewPresenter(output: self)

    // MARK: State

    private var cellTypes: [RecurrentPaymentCellType] = []
    private var moduleResult: PaymentResult = .cancelled()
    
    // MARK: Initialization

    init(
        paymentController: IPaymentController,
        paymentFlow: PaymentFlow,
        paymentSource: PaymentSourceData,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.paymentController = paymentController
        self.paymentFlow = paymentFlow
        self.paymentSource = paymentSource
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - IRecurrentPaymentViewOutput

extension RecurrentPaymentPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing)
        paymentController.performPayment(paymentFlow: paymentFlow, paymentSource: paymentSource)
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

// MARK: - PaymentControllerDelegate

extension RecurrentPaymentPresenter: PaymentControllerDelegate {
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

// MARK: - Private

extension RecurrentPaymentPresenter {
    private func activatePayButtonIfNeeded() {
        payButtonPresenter.set(enabled: savedCardPresenter.isValid)
    }

    private func startPaymentWithSavedCard() {
        payButtonPresenter.startLoading()
        paymentController.performPayment(paymentFlow: paymentFlow, paymentSource: paymentSource)
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
