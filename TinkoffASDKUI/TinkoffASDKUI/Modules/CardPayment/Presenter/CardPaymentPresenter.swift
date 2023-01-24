//
//  CardPaymentPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

enum CardPaymentCellType {
    case cardField
    case getReceipt
    case emailField
    case payButton
}

final class CardPaymentPresenter: ICardPaymentViewControllerOutput {

    // MARK: Dependencies

    weak var view: ICardPaymentViewControllerInput?
    private let router: ICardPaymentRouter

    // MARK: Properties

    private var cellTypes = [CardPaymentCellType]()
    private lazy var receiptSwitchViewPresenter = createReceiptSwitchViewPresenter()

    // MARK: Initialization

    init(router: ICardPaymentRouter) {
        self.router = router
    }
}

// MARK: - ICardPaymentViewControllerOutput

extension CardPaymentPresenter {
    func viewDidLoad() {
        view?.setPayButton(title: "Оплатить 1 070 724 ₽")
        setupCellTypes(isCardExist: false, isEmailExist: false)
        view?.reloadTableView()
    }

    func closeButtonPressed() {
        router.closeScreen()
    }

    func payButtonPressed() {
        print(#function)
    }

    func cardFieldDidChangeState(isValid: Bool) {
        print(isValid)
    }

    func numberOfRows() -> Int {
        cellTypes.count
    }

    func cellType(for row: Int) -> CardPaymentCellType {
        cellTypes[row]
    }

    func switchViewPresenter() -> SwitchViewPresenter {
        receiptSwitchViewPresenter
    }
}

// MARK: - Private

extension CardPaymentPresenter {
    private func createReceiptSwitchViewPresenter() -> SwitchViewPresenter {
        SwitchViewPresenter(title: "Получить квитанцию", isOn: false, actionBlock: { [weak self] isOn in
            guard let self = self else { return }

            if isOn {
                let getReceiptIndex = self.cellTypes.firstIndex(of: .getReceipt) ?? 0
                let emailIndex = getReceiptIndex + 1
                self.cellTypes.insert(.emailField, at: emailIndex)
                self.view?.insert(row: emailIndex)
            } else if let emailIndex = self.cellTypes.firstIndex(of: .emailField) {
                self.cellTypes.remove(at: emailIndex)
                self.view?.delete(row: emailIndex)
            }
        })
    }

    private func setupCellTypes(isCardExist: Bool, isEmailExist: Bool) {
        if !isCardExist, !isEmailExist {
            cellTypes = [.cardField, .getReceipt, .payButton]
        } else if !isCardExist, isEmailExist {
            cellTypes = [.cardField, .getReceipt, .emailField, .payButton]
        }
    }
}
