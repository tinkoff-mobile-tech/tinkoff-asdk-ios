//
//  CardPaymentPresenter.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

final class CardPaymentPresenter: ICardPaymentViewControllerOutput {

    // MARK: Dependencies

    weak var view: ICardPaymentViewControllerInput?
    private let router: ICardPaymentRouter

    // MARK: Properties

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

    func viewPresenter(for row: Int) -> SwitchViewPresenter {
        receiptSwitchViewPresenter
    }
}

// MARK: - Private

extension CardPaymentPresenter {
    func createReceiptSwitchViewPresenter() -> SwitchViewPresenter {
        SwitchViewPresenter(title: "Получить квитанцию", isOn: false, actionBlock: { isOn in
            // показать или убрать ячейку с имейлом
            print("свитч: \(isOn)")
        })
    }
}
