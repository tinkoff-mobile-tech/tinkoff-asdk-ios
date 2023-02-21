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

    private let cardsControllerAssembly: ICardsControllerAssembly
    private let paymentControllerAssembly: IPaymentControllerAssembly

    // MARK: Initialization

    init(
        cardsControllerAssembly: ICardsControllerAssembly,
        paymentControllerAssembly: IPaymentControllerAssembly
    ) {
        self.cardsControllerAssembly = cardsControllerAssembly
        self.paymentControllerAssembly = paymentControllerAssembly
    }

    // MARK: ICardPaymentAssembly

    func build(
        activeCards: [PaymentCard]?,
        paymentFlow: PaymentFlow,
        amount: Int64,
        output: ICardPaymentPresenterModuleOutput?
    ) -> UIViewController {
        let paymentController = paymentControllerAssembly.paymentController()
        let cardsController = cardsControllerAssembly.cardsController(customerKey: paymentFlow.customerOptions?.customerKey ?? "")

        let router = CardPaymentRouter()
        let presenter = CardPaymentPresenter(
            router: router,
            output: output,
            cardsController: cardsController,
            paymentController: paymentController,
            activeCards: activeCards,
            paymentFlow: paymentFlow,
            amount: Int(amount)
        )

        let view = CardPaymentViewController(presenter: presenter)
        presenter.view = view
        router.transitionHandler = view

        paymentController.delegate = presenter
        paymentController.webFlowDelegate = view

        return view
    }
}
