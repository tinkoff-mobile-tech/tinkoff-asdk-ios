//
//  CardPaymentAssembly.swift
//  TinkoffASDKUI
//
//  Created by Aleksandr Pravosudov on 20.01.2023.
//

import TinkoffASDKCore
import UIKit

final class CardPaymentAssembly: ICardPaymentAssembly {

    // MARK: Dependencies

    private let paymentControllerAssembly: IPaymentControllerAssembly

    // MARK: Initialization

    init(paymentControllerAssembly: IPaymentControllerAssembly) {
        self.paymentControllerAssembly = paymentControllerAssembly
    }

    // MARK: ICardPaymentAssembly

    func build(
        activeCards: [PaymentCard],
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()

        let router = CardPaymentRouter()
        let moneyFormatter = MoneyFormatter()
        let presenter = CardPaymentPresenter(
            router: router,
            output: output,
            paymentController: paymentController,
            moneyFormatter: moneyFormatter,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: Int(amount)
        )

        let view = CardPaymentViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view

        paymentController.delegate = presenter
        paymentController.uiProvider = view

        return view
    }
}
