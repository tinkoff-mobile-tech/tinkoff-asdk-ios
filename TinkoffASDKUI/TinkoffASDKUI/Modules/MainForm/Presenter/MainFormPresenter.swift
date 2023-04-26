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
    private let dataStateLoader: IMainFormDataStateLoader
    private let paymentController: IPaymentController
    private let tinkoffPayController: ITinkoffPayController
    private let paymentFlow: PaymentFlow
    private let configuration: MainFormUIConfiguration
    private weak var cardScannerDelegate: ICardScannerDelegate?
    private var moduleCompletion: PaymentResultCompletion?

    // MARK: Child Presenters

    private lazy var orderDetailsPresenter = MainFormOrderDetailsViewPresenter(
        amount: paymentFlow.amount,
        orderDescription: configuration.orderDescription
    )

    private lazy var savedCardPresenter = SavedCardViewPresenter(output: self)

    private lazy var getReceiptSwitchPresenter = SwitchViewPresenter(
        title: Loc.Acquiring.EmailField.switchButton,
        isOn: paymentFlow.customerOptions?.email?.isEmpty == false,
        actionBlock: { [weak self] in self?.getReceiptSwitch(didChange: $0) }
    )

    private lazy var emailPresenter = EmailViewPresenter(
        customerEmail: paymentFlow.customerOptions?.email ?? "",
        output: self
    )

    private lazy var payButtonPresenter = PayButtonViewPresenter(output: self)
    private lazy var otherPaymentMethodsHeaderPresenter = TextAndImageHeaderViewPresenter(title: Loc.CommonSheet.PaymentForm.anotherMethodTitle)

    // MARK: State

    private var presentationState: MainFormPresentationState = .loading
    private var dataState: MainFormDataState = .initial
    private var cellTypes: [MainFormCellType] = []
    private var moduleResult: PaymentResult = .cancelled()

    // MARK: Init

    init(
        router: IMainFormRouter,
        dataStateLoader: IMainFormDataStateLoader,
        paymentController: IPaymentController,
        tinkoffPayController: ITinkoffPayController,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        cardScannerDelegate: ICardScannerDelegate?,
        moduleCompletion: PaymentResultCompletion?
    ) {
        self.router = router
        self.dataStateLoader = dataStateLoader
        self.paymentController = paymentController
        self.tinkoffPayController = tinkoffPayController
        self.paymentFlow = paymentFlow
        self.configuration = configuration
        self.cardScannerDelegate = cardScannerDelegate
        self.moduleCompletion = moduleCompletion
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing, animatePullableContainerUpdates: false)

        dataStateLoader.loadState(for: paymentFlow) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(dataState):
                self.dataState = dataState
                self.savedCardPresenter.updatePresentationState(for: dataState.cards ?? [])
                self.reloadContent()
                self.presentationState = .payMethodsPresenting
                self.view?.hideCommonSheet()
            case let .failure(error):
                self.moduleResult = .failed(error)
                self.presentationState = .unrecoverableFailure
                self.view?.showCommonSheet(state: .somethingWentWrong)
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
            view?.hideKeyboard()
            startPayment(paymentMethod: paymentMethod)
        default:
            break
        }
    }

    func commonSheetViewDidTapPrimaryButton() {
        switch presentationState {
        case .payMethodsPresenting, .loading, .tinkoffPayProcessing:
            break
        case .paid, .unrecoverableFailure:
            view?.closeView()
        case .recoverableFailure:
            presentationState = .payMethodsPresenting
            payButtonPresenter.stopLoading()
            view?.hideCommonSheet()
        }
    }

    func commonSheetViewDidTapSecondaryButton() {
        switch presentationState {
        case .payMethodsPresenting, .loading, .paid, .unrecoverableFailure, .recoverableFailure:
            break
        case let .tinkoffPayProcessing(cancellable):
            presentationState = .payMethodsPresenting
            cancellable.cancel()
            view?.hideCommonSheet()
        }
    }
}

// MARK: - ISavedCardViewPresenterOutput

extension MainFormPresenter: ISavedCardViewPresenterOutput {
    func savedCardPresenter(
        _ presenter: SavedCardViewPresenter,
        didRequestReplacementFor paymentCard: PaymentCard
    ) {
        router.openCardPaymentList(
            paymentFlow: paymentFlow.withPrimaryMethodAnalytics(dataState: dataState),
            cards: dataState.cards ?? [],
            selectedCard: paymentCard,
            cardListOutput: self,
            cardPaymentOutput: self,
            cardScannerDelegate: cardScannerDelegate
        )
    }

    func savedCardPresenter(
        _ presenter: SavedCardViewPresenter,
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
        view?.hideKeyboard()

        switch dataState.primaryPaymentMethod {
        case .card where savedCardPresenter.presentationState.isSelected:
            startPaymentWithSavedCard()
        case .card, .tinkoffPay, .sbp:
            startPayment(paymentMethod: dataState.primaryPaymentMethod)
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
        presentationState = .paid
        view?.showCommonSheet(state: .paid)
    }

    func paymentController(
        _ controller: IPaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {
        moduleResult = .failed(error)
        presentationState = .recoverableFailure
        view?.showCommonSheet(state: .paymentFailed)
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

// MARK: - TinkoffPayControllerDelegate

extension MainFormPresenter: TinkoffPayControllerDelegate {
    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        didReceiveIntermediate paymentState: GetPaymentStatePayload
    ) {
        moduleResult = .cancelled(paymentState.toPaymentInfo())
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedDueToInabilityToOpenTinkoffPay url: URL,
        error: Error
    ) {
        moduleResult = .failed(error)

        router.openTinkoffPayLanding { [weak self] in
            self?.presentationState = .payMethodsPresenting
            self?.view?.hideCommonSheet()
        }
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithSuccessful paymentState: GetPaymentStatePayload
    ) {
        moduleResult = .succeeded(paymentState.toPaymentInfo())
        presentationState = .paid
        view?.showCommonSheet(state: .tinkoffPay.paid)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithFailed paymentState: GetPaymentStatePayload,
        error: Error
    ) {
        moduleResult = .failed(error)
        presentationState = .recoverableFailure
        view?.showCommonSheet(state: .tinkoffPay.failedPaymentOnMainFormFlow)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWithTimeout paymentState: GetPaymentStatePayload,
        error: Error
    ) {
        moduleResult = .failed(error)
        presentationState = .recoverableFailure
        view?.showCommonSheet(state: .tinkoffPay.timedOutOnMainFormFlow)
    }

    func tinkoffPayController(
        _ tinkoffPayController: ITinkoffPayController,
        completedWith error: Error
    ) {
        moduleResult = .failed(error)
        presentationState = .recoverableFailure
        view?.showCommonSheet(state: .tinkoffPay.timedOutOnMainFormFlow)
    }
}

// MARK: - ICardListPresenterOutput

extension MainFormPresenter: ICardListPresenterOutput {
    func cardList(didUpdate cards: [PaymentCard]) {
        dataState.cards = cards
        savedCardPresenter.updatePresentationState(for: cards)
        reloadContent()
    }

    func cardList(willCloseAfterSelecting card: PaymentCard) {
        savedCardPresenter.presentationState = .selected(card: card)
    }
}

// MARK: - ICardPaymentPresenterModuleOutput

extension MainFormPresenter: ICardPaymentPresenterModuleOutput {
    func cardPaymentWillCloseAfterFinishedPayment(with paymentData: FullPaymentData) {
        moduleResult = .succeeded(paymentData.payload.toPaymentInfo())
        presentationState = .paid
        view?.showCommonSheet(state: .paid)
    }

    func cardPaymentWillCloseAfterFailedPayment(with error: Error, cardId: String?, rebillId: String?) {
        moduleResult = .failed(error)
        presentationState = .recoverableFailure
        view?.showCommonSheet(state: .paymentFailed)
    }

    func cardPaymentDidCloseAfterCancelledPayment(with paymentProcess: PaymentProcess, cardId: String?, rebillId: String?) {
        moduleResult = .cancelled()
        view?.closeView()
    }
}

// MARK: - ISBPBanksModuleOutput

extension MainFormPresenter: ISBPBanksModuleOutput {
    func didLoaded(sbpBanks: [SBPBank]) {
        dataState.sbpBanks = sbpBanks
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
    private func activatePayButtonIfNeeded() {
        guard dataState.primaryPaymentMethod == .card else {
            payButtonPresenter.set(enabled: true)
            return
        }

        let isCvcValid = dataState.hasCards ? savedCardPresenter.isValid : true
        let isEmailValid = getReceiptSwitchPresenter.isOn ? emailPresenter.isEmailValid : true

        payButtonPresenter.set(enabled: isCvcValid && isEmailValid)
    }

    private func startPaymentWithSavedCard() {
        guard let cardId = savedCardPresenter.cardId,
              let cvc = savedCardPresenter.cvc,
              dataState.primaryPaymentMethod == .card,
              savedCardPresenter.presentationState.isSelected
        else {
            return assertionFailure("Something went wrong in presenter's logic")
        }

        let email = getReceiptSwitchPresenter.isOn ? emailPresenter.currentEmail : nil

        let paymentFlow = paymentFlow
            .replacing(customerEmail: email)
            .withPrimaryMethodAnalytics(dataState: dataState)
            .withSavedCardAnalytics()

        payButtonPresenter.startLoading()

        paymentController.performPayment(
            paymentFlow: paymentFlow,
            paymentSource: .savedCard(cardId: cardId, cvv: cvc)
        )
    }
}

// MARK: - MainFormPresenter + Routing

extension MainFormPresenter {
    private func startPayment(paymentMethod: MainFormPaymentMethod) {
        let paymentFlow = paymentFlow.withPrimaryMethodAnalytics(dataState: dataState)

        switch paymentMethod {
        case .card:
            router.openCardPayment(
                paymentFlow: paymentFlow,
                cards: dataState.cards,
                output: self,
                cardListOutput: self,
                cardScannerDelegate: cardScannerDelegate
            )
        case let .tinkoffPay(version):
            let cancellable = tinkoffPayController.performPayment(paymentFlow: paymentFlow, method: version)
            presentationState = .tinkoffPayProcessing(cancellable)
            view?.showCommonSheet(state: .tinkoffPay.processing)
        case .sbp:
            router.openSBP(paymentFlow: paymentFlow.withSBPAnalytics(), banks: dataState.sbpBanks, output: self, paymentSheetOutput: self)
        }
    }
}

// MARK: - MainFormPresenter + Rows Creations

extension MainFormPresenter {
    private func reloadContent() {
        payButtonPresenter.presentationState = .presentationState(from: dataState.primaryPaymentMethod)
        activatePayButtonIfNeeded()
        cellTypes = primaryPaymentMethodRows() + otherPaymentMethodsRows()
        view?.reloadData()
    }

    private func primaryPaymentMethodRows() -> [MainFormCellType] {
        var rows: [MainFormCellType] = [.orderDetails(orderDetailsPresenter)]

        switch dataState.primaryPaymentMethod {
        case .card where savedCardPresenter.presentationState.isSelected:
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

    private func otherPaymentMethodsRows() -> [MainFormCellType] {
        guard !dataState.otherPaymentMethods.isEmpty else { return [] }

        let header: MainFormCellType = .otherPaymentMethodsHeader(otherPaymentMethodsHeaderPresenter)
        return CollectionOfOne(header) + dataState.otherPaymentMethods.map(MainFormCellType.otherPaymentMethod)
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
        CommonSheetState(
            status: .succeeded,
            title: Loc.CommonSheet.Paid.title,
            primaryButtonTitle: Loc.CommonSheet.Paid.primaryButton
        )
    }

    static var paymentFailed: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonSheet.PaymentFailed.title,
            primaryButtonTitle: Loc.CommonSheet.PaymentFailed.primaryButton
        )
    }

    static var somethingWentWrong: CommonSheetState {
        CommonSheetState(
            status: .failed,
            title: Loc.CommonAlert.SomeProblem.title,
            description: Loc.CommonAlert.SomeProblem.description,
            primaryButtonTitle: Loc.CommonAlert.button
        )
    }
}
