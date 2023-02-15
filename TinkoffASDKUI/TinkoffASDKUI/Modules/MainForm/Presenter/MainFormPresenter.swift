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
    private let paymentController: IPaymentController
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
    private var activeCards: [PaymentCard] = []
    private var availablePaymentMethods: [MainFormPaymentMethod] = MainFormPaymentMethod.allCases
    private lazy var primaryPaymentMethod = stub.primaryPayMethod.domainModel

    // MARK: Init

    init(
        router: IMainFormRouter,
        coreSDK: AcquiringSdk,
        paymentController: IPaymentController,
        paymentFlow: PaymentFlow,
        configuration: MainFormUIConfiguration,
        stub: MainFormStub
    ) {
        self.router = router
        self.coreSDK = coreSDK
        self.paymentController = paymentController
        self.paymentFlow = paymentFlow
        self.configuration = configuration
        self.stub = stub
    }
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: .processing)

        // Временно
        loadCardsIfNeeded { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.payButtonPresenter.presentationState = .presentationState(from: self.primaryPaymentMethod)
                self.activatePayButtonIfNeeded()
                self.cellTypes = self.createRows()
                self.view?.hideCommonSheet()
                self.view?.reloadData()
            }
        }
    }

    func viewWasClosed() {}

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
        routeTo(paymentMethod: primaryPaymentMethod)
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
        _ controller: PaymentController,
        didFinishPayment: PaymentProcess,
        with state: GetPaymentStatePayload,
        cardId: String?,
        rebillId: String?
    ) {}

    func paymentController(
        _ controller: PaymentController,
        didFailed error: Error,
        cardId: String?,
        rebillId: String?
    ) {}

    func paymentController(
        _ controller: PaymentController,
        paymentWasCancelled: PaymentProcess,
        cardId: String?,
        rebillId: String?
    ) {}
}

// MARK: - MainFormPresenter + Helpers

extension MainFormPresenter {
    private func loadCardsIfNeeded(completion: @escaping VoidBlock) {
        guard let customerKey = paymentFlow.customerOptions?.customerKey else {
            return completion()
        }

        coreSDK.getCardList(data: GetCardListData(customerKey: customerKey)) { [weak self] result in
            DispatchQueue.main.async {
                guard let cards = try? result.get() else { return completion() }
                let activeCards = cards.filter { $0.status == .active }

                guard let selectedCard = activeCards.first else { return completion() }

                self?.activeCards = activeCards
                self?.savedCardPresenter.presentationState = .selected(
                    card: selectedCard,
                    hasAnotherCards: activeCards.count > 1
                )
                completion()
            }
        }
    }

    private func activatePayButtonIfNeeded() {
        guard primaryPaymentMethod == .card else {
            payButtonPresenter.set(enabled: true)
            return
        }

        let isCvcValid = activeCards.isEmpty ? true : savedCardPresenter.isValid
        let isEmailValid = getReceiptSwitchPresenter.isOn ? emailPresenter.isEmailValid : true

        payButtonPresenter.set(enabled: isCvcValid && isEmailValid)
    }
}

// MARK: - MainFormPresenter + Routing

extension MainFormPresenter {
    private func routeTo(paymentMethod: MainFormPaymentMethod) {
        switch paymentMethod {
        case .card:
            router.openCardPaymentForm(paymentFlow: paymentFlow, cards: activeCards, output: self)
        case .tinkoffPay:
            router.openTinkoffPay(paymentFlow: paymentFlow)
        case .sbp:
            router.openSBP(paymentFlow: paymentFlow)
        }
    }
}

// MARK: - MainFormPresenter + Rows Creations

extension MainFormPresenter {
    private func createRows() -> [MainFormCellType] {
        createPrimaryPaymentMethodRows() + createOtherPaymentMethodsRows()
    }

    private func createPrimaryPaymentMethodRows() -> [MainFormCellType] {
        var rows: [MainFormCellType] = [.orderDetails(orderDetailsPresenter)]

        switch primaryPaymentMethod {
        case .card where !activeCards.isEmpty:
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

    static var succeeded: CommonSheetState {
        CommonSheetState(status: .succeeded, title: "Оплачено", primaryButtonTitle: "Понятно")
    }
}
