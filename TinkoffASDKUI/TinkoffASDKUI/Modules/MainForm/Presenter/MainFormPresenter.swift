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
    private lazy var primaryPayMethod = stub.primaryPayMethod.domainModel

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
}

// MARK: - IMainFormPresenter

extension MainFormPresenter: IMainFormPresenter {
    func viewDidLoad() {
        view?.showCommonSheet(state: CommonSheetState(status: .processing, title: ""))

        loadCardsIfNeeded { [weak self] in
            guard let self = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.setupButtonAppearance()
                self.setupRows()
                self.view?.reloadData()
                self.view?.hideCommonSheet()
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
        case .otherPaymentMethod(.card):
            router.openCardPaymentForm(paymentFlow: paymentFlow, cards: activeCards, output: self)
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
    ) {}
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
    }
}

// MARK: - IPayButtonViewPresenterOutput

extension MainFormPresenter: IPayButtonViewPresenterOutput {
    func payButtonViewTapped(_ presenter: IPayButtonViewPresenterInput) {
        switch stub.primaryPayMethod {
        case .card:
            router.openCardPaymentForm(paymentFlow: paymentFlow, cards: activeCards, output: self)
        case .tinkoffPay:
            router.openTinkoffPay(paymentFlow: paymentFlow)
        case .sbp:
            router.openSBP(paymentFlow: paymentFlow)
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

    private func setupButtonAppearance() {
        payButtonPresenter.presentationState = .presentationState(from: primaryPayMethod)
    }

    func setupRows() {
        cellTypes = createPrimaryPaymentMethodSection() + createOtherPaymentMethodsSection()
    }

    private func createPrimaryPaymentMethodSection() -> [MainFormCellType] {
        var rows: [MainFormCellType] = [.orderDetails(orderDetailsPresenter)]

        switch primaryPayMethod {
        case .tinkoffPay, .sbp:
            break
        case .card:
            if !activeCards.isEmpty {
                rows.append(.savedCard(savedCardPresenter))
            }

            rows.append(.getReceiptSwitch(getReceiptSwitchPresenter))

            if getReceiptSwitchPresenter.isOn {
                rows.append(.email(emailPresenter))
            }
        }

        rows.append(.payButton(payButtonPresenter))

        return rows
    }

    private func createOtherPaymentMethodsSection() -> [MainFormCellType] {
        let otherPaymentMethods = MainFormPaymentMethod
            .allCases
            .filter(availablePaymentMethods.contains)
            .filter { $0 != primaryPayMethod }
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
